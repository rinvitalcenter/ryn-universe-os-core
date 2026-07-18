import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ryn_universe_os_core/core/persistence/runtime_data_profile.dart';
import 'package:ryn_universe_os_core/features/tarot/application/tarot_runtime_controller.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_restore_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_restore_startup_recovery_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_restore_operation_marker.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_restore_candidate_validator.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  TarotBackupRecoveryFixture? fixture;
  _RecoverySetup? setup;

  tearDown(() async {
    setup?.lifecycle.dispose();
    setup = null;
    await fixture?.dispose();
    fixture = null;
  });

  Future<_RecoverySetup> createSetup() async {
    fixture = await TarotBackupRecoveryFixture.create();
    final candidate = await fixture!.createRestoreCandidate(
      operationId: 'a1b2c3d4',
    );
    final database = fixture!.openSource();
    fixture!.insertValidReading(database, id: 'synthetic-r2');
    fixture!.release(database);
    final safety = await fixture!.createRestoreCandidate(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 3, 4),
      operationId: 'b1c2d3e4',
    );
    final operationDirectory = Directory(
      p.join(fixture!.sourceRoot.path, '.restore-deadbeef'),
    );
    final lifecycle = _RecoveryLifecycle(fixture!.sourceFile);
    final result = _RecoverySetup(
      candidate: candidate,
      safety: safety,
      operationDirectory: operationDirectory,
      lifecycle: lifecycle,
    );
    setup = result;
    return result;
  }

  TarotRestoreStartupRecoveryCoordinator coordinator({
    TarotRestoreFileRename? renameFile,
  }) => TarotRestoreStartupRecoveryCoordinator(
    candidateValidator: TarotRestoreCandidateValidator(
      inspectPath: (_) async => true,
    ),
    renameFile: renameFile,
  );

  Future<void> writeMarker(
    _RecoverySetup value,
    TarotRestoreMarkerStage stage,
  ) async {
    await value.operationDirectory.create();
    await const TarotRestoreOperationMarkerStore().write(
      operationDirectory: value.operationDirectory,
      paths: fixture!.resolvedPaths(),
      marker: TarotRestoreOperationMarker(
        operationId: 'deadbeef',
        stage: stage,
        liveDatabasePath: fixture!.sourceFile.absolute.path,
        preservedOriginalDirectory: value.operationDirectory.absolute.path,
        candidatePackagePath: value.candidate.absolute.path,
        safetyBackupPackagePath: value.safety.absolute.path,
        startedAtUtc: DateTime.utc(2026, 7, 17, 2),
        updatedAtUtc: DateTime.utc(2026, 7, 17, 2, 1),
      ),
    );
  }

  Future<TarotRestoreStartupRecoveryResult> recover(
    _RecoverySetup value, {
    TarotRestoreStartupRecoveryCoordinator? using,
  }) => (using ?? coordinator()).recoverIfNeeded(
    liveDatabasePath: fixture!.sourceFile.path,
    resolvedPaths: fixture!.resolvedPaths(),
    lifecycle: value.lifecycle,
  );

  test('no marker means no recovery action', () async {
    final value = await createSetup();
    final before = await fixture!.sourceFile.readAsBytes();

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.noAction);
    expect(await fixture!.sourceFile.readAsBytes(), before);
    expect(value.lifecycle.reopenCount, 0);
  });

  test('prepared cleans operation residue without live mutation', () async {
    final value = await createSetup();
    await writeMarker(value, TarotRestoreMarkerStage.prepared);
    final residue = File(p.join(value.operationDirectory.path, 'restore.tmp'));
    await residue.writeAsBytes(const <int>[1, 2, 3], flush: true);
    final before = await fixture!.sourceFile.readAsBytes();

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.finalizedPrepared);
    expect(await fixture!.sourceFile.readAsBytes(), before);
    expect(value.operationDirectory.existsSync(), isFalse);
    expect(value.lifecycle.reopenCount, 0);
  });

  test('originalPreserved restores original DB', () async {
    final value = await createSetup();
    await _preserveOriginal(value);
    await writeMarker(value, TarotRestoreMarkerStage.originalPreserved);

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.originalRecovered);
    expect(_readingCount(fixture!.sourceFile), 2);
    expect(value.lifecycle.reopenCount, 1);
    expect(value.lifecycle.validateCount, 1);
    expect(value.operationDirectory.existsSync(), isFalse);
  });

  test('candidateInstalled rolls back to original DB', () async {
    final value = await createSetup();
    await _preserveOriginal(value);
    await _installCandidate(value);
    await writeMarker(value, TarotRestoreMarkerStage.candidateInstalled);

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.originalRecovered);
    expect(_readingCount(fixture!.sourceFile), 2);
    expect(value.lifecycle.reopenCount, 1);
    expect(value.operationDirectory.existsSync(), isFalse);
  });

  test('replacementVerified keeps replacement and finalizes', () async {
    final value = await createSetup();
    await _preserveOriginal(value);
    await _installCandidate(value);
    await writeMarker(value, TarotRestoreMarkerStage.replacementVerified);

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.replacementKept);
    expect(_readingCount(fixture!.sourceFile), 1);
    expect(value.operationDirectory.existsSync(), isFalse);
    expect(value.safety.existsSync(), isTrue);
  });

  test('rollbackStarted retries rollback', () async {
    final value = await createSetup();
    await _preserveOriginal(value);
    await _installCandidate(value);
    await writeMarker(value, TarotRestoreMarkerStage.rollbackStarted);

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.originalRecovered);
    expect(_readingCount(fixture!.sourceFile), 2);
  });

  test('rollbackCompleted verifies original and finalizes', () async {
    final value = await createSetup();
    await value.operationDirectory.create();
    await writeMarker(value, TarotRestoreMarkerStage.rollbackCompleted);

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.originalRecovered);
    expect(_readingCount(fixture!.sourceFile), 2);
    expect(value.lifecycle.reopenCount, 1);
    expect(value.operationDirectory.existsSync(), isFalse);
  });

  test('fatalPreserved performs no destructive action', () async {
    final value = await createSetup();
    await _preserveOriginal(value);
    await _installCandidate(value);
    await writeMarker(value, TarotRestoreMarkerStage.fatalPreserved);
    final liveBefore = await fixture!.sourceFile.readAsBytes();
    final preservedBefore = await File(
      p.join(
        value.operationDirectory.path,
        p.basename(fixture!.sourceFile.path),
      ),
    ).readAsBytes();

    final result = await recover(value);

    expect(
      result.status,
      TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
    );
    expect(await fixture!.sourceFile.readAsBytes(), liveBefore);
    expect(
      await File(
        p.join(
          value.operationDirectory.path,
          p.basename(fixture!.sourceFile.path),
        ),
      ).readAsBytes(),
      preservedBefore,
    );
    expect(value.operationDirectory.existsSync(), isTrue);
  });

  test('corrupted marker fails closed', () async {
    final value = await createSetup();
    await value.operationDirectory.create();
    final marker = File(
      p.join(
        value.operationDirectory.path,
        TarotRestoreOperationMarkerStore.filename,
      ),
    );
    await marker.writeAsString('{', flush: true);
    final before = await fixture!.sourceFile.readAsBytes();

    final result = await recover(value);

    expect(
      result.status,
      TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
    );
    expect(await fixture!.sourceFile.readAsBytes(), before);
    expect(marker.existsSync(), isTrue);
  });

  test('unknown marker stage fails closed', () async {
    final value = await createSetup();
    await value.operationDirectory.create();
    final valid = TarotRestoreOperationMarker(
      operationId: 'deadbeef',
      stage: TarotRestoreMarkerStage.prepared,
      liveDatabasePath: fixture!.sourceFile.absolute.path,
      preservedOriginalDirectory: value.operationDirectory.absolute.path,
      candidatePackagePath: value.candidate.absolute.path,
      safetyBackupPackagePath: value.safety.absolute.path,
      startedAtUtc: DateTime.utc(2026, 7, 17, 2),
      updatedAtUtc: DateTime.utc(2026, 7, 17, 2, 1),
    );
    final decoded =
        jsonDecode(const TarotRestoreOperationMarkerStore().encode(valid))
            as Map<String, Object?>;
    decoded['stage'] = 'unknown';
    final marker = File(
      p.join(
        value.operationDirectory.path,
        TarotRestoreOperationMarkerStore.filename,
      ),
    );
    await marker.writeAsString(jsonEncode(decoded), flush: true);
    final before = await fixture!.sourceFile.readAsBytes();

    final result = await recover(value);

    expect(
      result.status,
      TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
    );
    expect(await fixture!.sourceFile.readAsBytes(), before);
    expect(marker.existsSync(), isTrue);
  });

  test('original WAL SHM journal set is restored', () async {
    final value = await createSetup();
    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      await File(
        '${fixture!.sourceFile.path}$suffix',
      ).writeAsBytes(const <int>[], flush: true);
    }
    await _preserveOriginal(value);
    await _installCandidate(value);
    await writeMarker(value, TarotRestoreMarkerStage.candidateInstalled);

    final result = await recover(value);

    expect(result.status, TarotRestoreStartupRecoveryStatus.originalRecovered);
    for (final suffix in const <String>['-wal', '-shm', '-journal']) {
      final sidecar = File('${fixture!.sourceFile.path}$suffix');
      expect(sidecar.existsSync(), isTrue, reason: suffix);
      expect(sidecar.lengthSync(), 0, reason: suffix);
    }
  });

  test(
    'recovery failure preserves evidence and returns fatal result',
    () async {
      final value = await createSetup();
      await _preserveOriginal(value);
      await _installCandidate(value);
      await writeMarker(value, TarotRestoreMarkerStage.candidateInstalled);
      final livePath = p.normalize(fixture!.sourceFile.absolute.path);

      final result = await recover(
        value,
        using: coordinator(
          renameFile: (source, target) async {
            final restoringOriginal =
                p.dirname(source.path) == value.operationDirectory.path &&
                p.basename(source.path) == p.basename(livePath) &&
                p.normalize(File(target).absolute.path) == livePath;
            if (restoringOriginal) {
              throw StateError('synthetic recovery failure');
            }
            await source.rename(target);
          },
        ),
      );

      expect(
        result.status,
        TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
      );
      expect(value.operationDirectory.existsSync(), isTrue);
      final marker = await const TarotRestoreOperationMarkerStore().read(
        operationDirectory: value.operationDirectory,
        paths: fixture!.resolvedPaths(),
      );
      expect(marker.stage, TarotRestoreMarkerStage.fatalPreserved);
      expect(value.safety.existsSync(), isTrue);
    },
  );

  test(
    'runtime bootstrap runs prepared recovery before database open',
    () async {
      final value = await createSetup();
      final runtimePaths = RynRuntimeDataPathContract.forApplicationSupportRoot(
        fixture!.root,
      );
      final resolved = runtimePaths.resolveMode(
        RynRuntimeDataMode.tarotBackupRecoveryQa,
      );
      await Directory(resolved.runtimeDirectoryPath).create(recursive: true);
      await fixture!.sourceFile.copy(resolved.databasePath);
      await Directory(resolved.backupOutputDirectoryPath).create();
      final safety = await value.safety.rename(
        p.join(
          resolved.backupOutputDirectoryPath,
          p.basename(value.safety.path),
        ),
      );
      final operationDirectory = Directory(
        p.join(resolved.runtimeDirectoryPath, '.restore-deadbeef'),
      );
      await operationDirectory.create();
      final paths = TarotBackupPathContract(
        sourceRootPath: resolved.runtimeDirectoryPath,
        backupRootPath: resolved.backupOutputDirectoryPath,
        protectedRootPaths: const <String>[],
        inspectPath: (_) async => true,
      ).resolve();
      await const TarotRestoreOperationMarkerStore().write(
        operationDirectory: operationDirectory,
        paths: paths,
        marker: TarotRestoreOperationMarker(
          operationId: 'deadbeef',
          stage: TarotRestoreMarkerStage.prepared,
          liveDatabasePath: File(resolved.databasePath).absolute.path,
          preservedOriginalDirectory: operationDirectory.absolute.path,
          candidatePackagePath: safety.absolute.path,
          safetyBackupPackagePath: safety.absolute.path,
          startedAtUtc: DateTime.utc(2026, 7, 17, 2),
          updatedAtUtc: DateTime.utc(2026, 7, 17, 2, 1),
        ),
      );
      final controller = TarotRuntimeController.development(
        pathContract: runtimePaths,
        runtimeDataMode: RynRuntimeDataMode.tarotBackupRecoveryQa,
        startupRecoveryCoordinator: coordinator(),
      );

      await controller.bootstrap();

      expect(
        controller.startupRecoveryResult?.status,
        TarotRestoreStartupRecoveryStatus.finalizedPrepared,
      );
      expect(controller.startupStatus, TarotRuntimeStartupStatus.readyWithData);
      expect(operationDirectory.existsSync(), isFalse);
      expect(controller.databasePath, resolved.databasePath);
      await controller.close();
    },
  );
}

final class _RecoverySetup {
  const _RecoverySetup({
    required this.candidate,
    required this.safety,
    required this.operationDirectory,
    required this.lifecycle,
  });

  final Directory candidate;
  final Directory safety;
  final Directory operationDirectory;
  final _RecoveryLifecycle lifecycle;
}

final class _RecoveryLifecycle implements TarotRestoreRuntimeLifecycle {
  _RecoveryLifecycle(this.liveFile);

  final File liveFile;
  Database? _database;
  int reopenCount = 0;
  int validateCount = 0;

  @override
  Future<void> close() async {
    _database?.close();
    _database = null;
  }

  @override
  Future<void> reopen() async {
    reopenCount += 1;
    _database = sqlite3.open(liveFile.path);
  }

  @override
  Future<void> validateBasicRead() async {
    validateCount += 1;
    if (_database?.select('SELECT 1').single.values.single != 1) {
      throw StateError('basic read failed');
    }
  }

  void dispose() {
    _database?.close();
    _database = null;
  }
}

Future<void> _preserveOriginal(_RecoverySetup setup) async {
  await setup.operationDirectory.create();
  for (final source in <File>[
    _fixtureFile(setup),
    for (final suffix in const <String>['-wal', '-shm', '-journal'])
      File('${_fixtureFile(setup).path}$suffix'),
  ]) {
    if (!source.existsSync()) continue;
    await source.rename(
      p.join(setup.operationDirectory.path, p.basename(source.path)),
    );
  }
}

Future<void> _installCandidate(_RecoverySetup setup) async {
  final snapshot = File(
    p.join(
      setup.candidate.path,
      'data',
      'ryn_universe_os_core_snapshot.sqlite',
    ),
  );
  await snapshot.copy(_fixtureFile(setup).path);
}

File _fixtureFile(_RecoverySetup setup) {
  return File(p.join(setup.operationDirectory.parent.path, 'source.sqlite'));
}

int _readingCount(File file) {
  final database = sqlite3.open(file.path, mode: OpenMode.readOnly);
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
