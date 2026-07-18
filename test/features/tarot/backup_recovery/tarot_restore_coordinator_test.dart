import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_backup_snapshot_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_restore_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_restore_operation_marker.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_restore_operation_result.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_restore_candidate_validator.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  TarotBackupRecoveryFixture? fixture;
  final lifecycles = <_TestLifecycle>[];

  tearDown(() async {
    for (final lifecycle in lifecycles) {
      lifecycle.dispose();
    }
    lifecycles.clear();
    await fixture?.dispose();
    fixture = null;
  });

  Future<_RestoreSetup> createSetup({
    bool mutateLiveAfterCandidate = true,
    Future<bool> Function(String)? inspectPath,
  }) async {
    fixture = await TarotBackupRecoveryFixture.create();
    final package = await fixture!.createRestoreCandidate();
    if (mutateLiveAfterCandidate) {
      final database = fixture!.openSource();
      fixture!.insertValidReading(database, id: 'synthetic-r2');
      fixture!.release(database);
    }
    final lifecycle = _TestLifecycle(fixture!.sourceFile);
    lifecycle.openInitial();
    lifecycles.add(lifecycle);
    return _RestoreSetup(
      package: package,
      lifecycle: lifecycle,
      paths: fixture!.resolvedPaths(inspectPath: inspectPath),
    );
  }

  TarotRestoreCoordinator coordinator({
    TarotRestoreCandidateValidator? validator,
    TarotSafetyBackupCreator? createSafetyBackup,
    TarotRestoreFileCopy? copyFile,
    TarotRestoreFileRename? renameFile,
  }) => TarotRestoreCoordinator(
    candidateValidator:
        validator ??
        TarotRestoreCandidateValidator(inspectPath: (_) async => true),
    backupCoordinator: TarotBackupSnapshotCoordinator(
      clock: () => DateTime.utc(2026, 7, 17, 2, 3, 4),
      operationIdGenerator: () => 'b1c2d3e4',
    ),
    createSafetyBackup: createSafetyBackup,
    copyFile: copyFile,
    renameFile: renameFile,
  );

  Future<TarotRestoreOperationResult> restore(
    _RestoreSetup setup, {
    TarotRestoreCoordinator? using,
    String operationId = 'deadbeef',
  }) => (using ?? coordinator()).restore(
    candidatePackagePath: setup.package.path,
    liveDatabasePath: fixture!.sourceFile.path,
    resolvedPaths: setup.paths,
    sourceProfileEvidence: const TarotBackupSourceProfileEvidence.syntheticQa(),
    applicationVersion: '1.0.0+1',
    operationId: operationId,
    lifecycle: setup.lifecycle,
  );

  test('valid candidate restores successfully', () async {
    final setup = await createSetup();

    final result = await restore(setup);

    expect(result.status, TarotRestoreOperationStatus.succeeded);
    expect(result.isSuccess, isTrue);
    expect(_readingCount(fixture!.sourceFile), 1);
    expect(setup.lifecycle.closeCount, 1);
    expect(setup.lifecycle.reopenCount, 1);
    expect(setup.lifecycle.validateCount, 1);
  });

  test(
    'invalid candidate causes zero safety copy close and mutation',
    () async {
      final setup = await createSetup();
      await File('${setup.package.path}/manifest.json').writeAsString('{');
      var safetyCount = 0;
      final before = await _sourceTree(fixture!.sourceRoot);

      final result = await restore(
        setup,
        using: coordinator(
          createSafetyBackup: (_, _, _, _) async {
            safetyCount += 1;
            throw StateError('must not run');
          },
        ),
      );

      expect(result.status, TarotRestoreOperationStatus.failedBeforeMutation);
      expect(safetyCount, 0);
      expect(setup.lifecycle.closeCount, 0);
      expect(await _sourceTree(fixture!.sourceRoot), before);
    },
  );

  test('safety backup failure causes zero live mutation', () async {
    final setup = await createSetup();
    final before = await _sourceTree(fixture!.sourceRoot);

    final result = await restore(
      setup,
      using: coordinator(
        createSafetyBackup: (_, _, _, _) async =>
            throw StateError('synthetic safety failure'),
      ),
    );

    expect(result.status, TarotRestoreOperationStatus.failedBeforeMutation);
    expect(result.failureCode, 'safety_backup_failed');
    expect(setup.lifecycle.closeCount, 0);
    expect(await _sourceTree(fixture!.sourceRoot), before);
  });

  test(
    'runtime close failure leaves prepared marker before replacement',
    () async {
      final setup = await createSetup();
      setup.lifecycle.failClose = true;
      final liveBefore = await fixture!.sourceFile.readAsBytes();

      final result = await restore(setup);

      expect(result.status, TarotRestoreOperationStatus.failedBeforeMutation);
      expect(result.failureCode, 'runtime_close_failed');
      expect(setup.lifecycle.closeCount, 1);
      expect(await fixture!.sourceFile.readAsBytes(), liveBefore);
      final operationDirectory = Directory(
        p.join(fixture!.sourceRoot.path, '.restore-deadbeef'),
      );
      final marker = await const TarotRestoreOperationMarkerStore().read(
        operationDirectory: operationDirectory,
        paths: setup.paths,
      );
      expect(marker.stage, TarotRestoreMarkerStage.prepared);
    },
  );

  test('candidate copy or rename failure restores original DB', () async {
    for (final failure in <String>['copy', 'installRename']) {
      final setup = await createSetup();
      final beforeCount = _readingCount(fixture!.sourceFile);
      var copyStarted = false;
      var installFailureInjected = false;
      final result = await restore(
        setup,
        using: coordinator(
          copyFile: failure == 'copy'
              ? (source, target) async {
                  copyStarted = true;
                  await target.writeAsBytes(<int>[1], flush: true);
                  throw StateError('synthetic copy failure');
                }
              : null,
          renameFile: failure == 'installRename'
              ? (source, target) async {
                  if (source.path.contains('.restore-deadbeef.tmp') &&
                      !installFailureInjected) {
                    installFailureInjected = true;
                    throw StateError('synthetic install rename failure');
                  }
                  await source.rename(target);
                }
              : null,
        ),
      );

      expect(
        result.status,
        TarotRestoreOperationStatus.failedRolledBack,
        reason: '$failure ${result.failureCode}',
      );
      expect(result.originalRestored, isTrue);
      expect(_readingCount(fixture!.sourceFile), beforeCount);
      if (failure == 'copy') expect(copyStarted, isTrue);
      await setup.lifecycle.close();
      lifecycles.remove(setup.lifecycle);
      await fixture!.dispose();
      fixture = null;
    }
  });

  test('new DB reopen failure restores original DB', () async {
    final setup = await createSetup();
    final beforeCount = _readingCount(fixture!.sourceFile);
    setup.lifecycle.failNextReopen = true;

    final result = await restore(setup);

    expect(result.status, TarotRestoreOperationStatus.failedRolledBack);
    expect(result.originalRestored, isTrue);
    expect(_readingCount(fixture!.sourceFile), beforeCount);
    expect(setup.lifecycle.reopenCount, 2);
  });

  test('new DB validation failure restores original DB', () async {
    final setup = await createSetup();
    final beforeCount = _readingCount(fixture!.sourceFile);
    setup.lifecycle.failNextValidation = true;

    final result = await restore(setup);

    expect(result.status, TarotRestoreOperationStatus.failedRolledBack);
    expect(result.originalRestored, isTrue);
    expect(_readingCount(fixture!.sourceFile), beforeCount);
    expect(setup.lifecycle.validateCount, 2);
  });

  test('original WAL SHM journal set is preserved and restored', () async {
    final setup = await createSetup();
    setup.lifecycle.createZeroSidecarsOnFirstClose = true;
    setup.lifecycle.failNextReopen = true;

    final result = await restore(setup);

    expect(result.status, TarotRestoreOperationStatus.failedRolledBack);
    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      final sidecar = File('${fixture!.sourceFile.path}$suffix');
      expect(sidecar.existsSync(), isTrue, reason: suffix);
      expect(sidecar.lengthSync(), 0, reason: suffix);
    }
  });

  test('successful restore retains verified safety backup', () async {
    final setup = await createSetup();

    final result = await restore(setup);

    expect(result.status, TarotRestoreOperationStatus.succeeded);
    expect(result.safetyBackupPackagePath, isNotNull);
    expect(Directory(result.safetyBackupPackagePath!).existsSync(), isTrue);
    expect(result.safetyBackupPackagePath, isNot(equals(setup.package.path)));
  });

  test(
    'rollback failure returns fatal result and preserves evidence',
    () async {
      final setup = await createSetup();
      setup.lifecycle.failNextReopen = true;
      final livePath = p.normalize(fixture!.sourceFile.absolute.path);

      final result = await restore(
        setup,
        using: coordinator(
          renameFile: (source, target) async {
            final restoringOriginal =
                source.path.contains('.restore-deadbeef') &&
                p.normalize(File(target).absolute.path) == livePath &&
                p.basename(source.path) == p.basename(livePath);
            if (restoringOriginal) {
              throw StateError('synthetic rollback failure');
            }
            await source.rename(target);
          },
        ),
      );

      expect(result.status, TarotRestoreOperationStatus.fatalRecoveryRequired);
      expect(result.isSuccess, isFalse);
      expect(result.originalRestored, isFalse);
      expect(result.preservedEvidencePath, isNotNull);
      expect(Directory(result.preservedEvidencePath!).existsSync(), isTrue);
      expect(Directory(result.safetyBackupPackagePath!).existsSync(), isTrue);
    },
  );

  test('original DB remains readable after successful rollback', () async {
    final setup = await createSetup();
    setup.lifecycle.failNextValidation = true;

    final result = await restore(setup);

    expect(result.status, TarotRestoreOperationStatus.failedRolledBack);
    final database = sqlite3.open(
      fixture!.sourceFile.path,
      mode: OpenMode.readOnly,
    );
    try {
      expect(database.select('SELECT 1').single.values.single, 1);
      expect(
        database
            .select('SELECT count(*) FROM tarot_readings')
            .single
            .values
            .single,
        2,
      );
    } finally {
      database.close();
    }
  });

  test('no protected path or actual personal data is used', () async {
    final inspected = <String>[];
    final setup = await createSetup(
      inspectPath: (path) async {
        inspected.add(path);
        return true;
      },
    );
    final validator = TarotRestoreCandidateValidator(
      inspectPath: (path) async {
        inspected.add(path);
        return true;
      },
      protectedRootPaths: const <String>[
        r'C:\Users\hahac\AppData\Roaming\RinVitalCenter\RynUniverseOS',
        r'C:\Users\hahac\Downloads\Ryn Universe OS Backups',
      ],
    );

    final result = await restore(
      setup,
      using: coordinator(validator: validator),
    );

    expect(result.status, TarotRestoreOperationStatus.succeeded);
    final root = p.normalize(fixture!.root.absolute.path).toLowerCase();
    expect(inspected, isNotEmpty);
    expect(
      inspected.every(
        (path) => p
            .normalize(File(path).absolute.path)
            .toLowerCase()
            .startsWith(root),
      ),
      isTrue,
    );
    expect(
      inspected.join('|').toLowerCase(),
      isNot(contains('rinvitalcenter')),
    );
  });
}

final class _RestoreSetup {
  const _RestoreSetup({
    required this.package,
    required this.lifecycle,
    required this.paths,
  });

  final Directory package;
  final _TestLifecycle lifecycle;
  final ResolvedBackupRecoveryPaths paths;
}

final class _TestLifecycle implements TarotRestoreRuntimeLifecycle {
  _TestLifecycle(this.liveFile);

  final File liveFile;
  Database? _database;
  bool failClose = false;
  bool failNextReopen = false;
  bool failNextValidation = false;
  bool createZeroSidecarsOnFirstClose = false;
  int closeCount = 0;
  int reopenCount = 0;
  int validateCount = 0;

  void openInitial() {
    _database = sqlite3.open(liveFile.path);
  }

  @override
  Future<void> close() async {
    closeCount += 1;
    if (failClose) throw StateError('synthetic close failure');
    _database?.close();
    _database = null;
    if (createZeroSidecarsOnFirstClose && closeCount == 1) {
      for (final suffix in const <String>['-wal', '-shm', '-journal']) {
        File('${liveFile.path}$suffix').writeAsBytesSync(const <int>[]);
      }
    }
  }

  @override
  Future<void> reopen() async {
    reopenCount += 1;
    if (failNextReopen) {
      failNextReopen = false;
      throw StateError('synthetic reopen failure');
    }
    _database = sqlite3.open(liveFile.path);
  }

  @override
  Future<void> validateBasicRead() async {
    validateCount += 1;
    if (failNextValidation) {
      failNextValidation = false;
      throw StateError('synthetic validation failure');
    }
    if (_database?.select('SELECT 1').single.values.single != 1) {
      throw StateError('basic read failed');
    }
  }

  void dispose() {
    _database?.close();
    _database = null;
  }
}

int _readingCount(File databaseFile) {
  final database = sqlite3.open(databaseFile.path, mode: OpenMode.readOnly);
  try {
    return database
            .select('SELECT count(*) FROM tarot_readings')
            .single
            .values
            .single
        as int;
  } finally {
    database.close();
  }
}

Future<Map<String, List<int>>> _sourceTree(Directory root) async {
  final result = <String, List<int>>{};
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (FileSystemEntity.typeSync(entity.path, followLinks: false) ==
        FileSystemEntityType.file) {
      result[p.relative(entity.path, from: root.path)] = await File(
        entity.path,
      ).readAsBytes();
    }
  }
  return result;
}
