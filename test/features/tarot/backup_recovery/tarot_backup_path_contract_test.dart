import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';

void main() {
  late Directory temp;
  late Directory sourceRoot;
  late Directory backupRoot;
  late List<String> inspections;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('ryn-backup-path-');
    sourceRoot = Directory('${temp.path}${Platform.pathSeparator}qa-source');
    backupRoot = Directory('${temp.path}${Platform.pathSeparator}qa-backup');
    inspections = <String>[];
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  TarotBackupPathContract contract({List<String> protectedRoots = const []}) =>
      TarotBackupPathContract(
        sourceRootPath: sourceRoot.path,
        backupRootPath: backupRoot.path,
        protectedRootPaths: protectedRoots,
        inspectPath: (path) async {
          inspections.add(path);
          return true;
        },
      );

  test('standard conceptual root is exact and pure', () {
    final downloads = '${temp.path}${Platform.pathSeparator}Downloads';
    final root = TarotBackupPathContract.standardConceptualBackupRoot(
      downloads,
    );

    expect(root, '$downloads${Platform.pathSeparator}Ryn Universe OS Backups');
    expect(Directory(downloads).existsSync(), isFalse);
    expect(Directory(root).existsSync(), isFalse);
  });

  test('injected QA resolution is exact and creates no directories', () {
    final resolved = contract().resolve();

    expect(resolved.sourceRootPath, sourceRoot.absolute.path);
    expect(resolved.backupRootPath, backupRoot.absolute.path);
    expect(sourceRoot.existsSync(), isFalse);
    expect(backupRoot.existsSync(), isFalse);
  });

  test(
    'protected runtime production repository and Obsidian roots fail closed',
    () {
      final protected = <String>[
        '${temp.path}${Platform.pathSeparator}runtime',
        '${temp.path}${Platform.pathSeparator}production',
        'C:${Platform.pathSeparator}dev${Platform.pathSeparator}ryn_universe_os_core',
        'C:${Platform.pathSeparator}Ryn_Universe_Wiki',
      ];

      for (final root in protected) {
        expect(
          () => TarotBackupPathContract(
            sourceRootPath: sourceRoot.path,
            backupRootPath: root,
            protectedRootPaths: protected,
            inspectPath: (_) async => true,
          ).resolve(),
          throwsA(isA<TarotBackupPathException>()),
        );
      }
    },
  );

  test('unsafe relative paths are rejected', () {
    final resolved = contract().resolve();
    for (final value in <String>[
      '../manifest.json',
      r'data\..\manifest.json',
      r'C:\absolute.sqlite',
      r'data\payload.sqlite:secret',
      r'\\?\C:\device',
      r'\\.\PhysicalDrive0',
      '/absolute/path',
      'nested.rynbackup/data/file',
    ]) {
      expect(
        () => resolved.validateSafeRelativePath(value),
        throwsA(isA<TarotBackupPathException>()),
        reason: value,
      );
    }
  });

  test('source and target must remain in distinct allowlisted roots', () {
    final resolved = contract().resolve();
    final validSource =
        '${sourceRoot.path}${Platform.pathSeparator}source.sqlite';
    final validTarget =
        '${backupRoot.path}${Platform.pathSeparator}.partial'
        '${Platform.pathSeparator}data${Platform.pathSeparator}target.sqlite';

    expect(
      () => resolved.validateSourceDatabasePath(validSource),
      returnsNormally,
    );
    expect(
      () => resolved.validateTargetSnapshotPath(validTarget),
      returnsNormally,
    );
    expect(
      () => resolved.validateSourceDatabasePath(validTarget),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(
      () => resolved.validateTargetSnapshotPath(validSource),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(
      () => resolved.validateTargetSnapshotPath(validSource),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(
      () => resolved.validateSourceDatabasePath(
        '${sourceRoot.path}${Platform.pathSeparator}..'
        '${Platform.pathSeparator}outside.sqlite',
      ),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(
      () => resolved.validateTargetSnapshotPath(
        '${backupRoot.path}${Platform.pathSeparator}..'
        '${Platform.pathSeparator}outside.sqlite',
      ),
      throwsA(isA<TarotBackupPathException>()),
    );
  });

  test('valid naming is deterministic lowercase and collision safe', () async {
    await backupRoot.create(recursive: true);
    final resolved = contract().resolve();
    final names = resolved.packagePaths(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
      operationId: 'a1b2c3d4',
    );

    expect(
      names.finalDirectory.path,
      endsWith('RynTarotBackup_20260717T010203Z_a1b2c3d4.rynbackup'),
    );
    expect(
      names.partialDirectory.path,
      endsWith(
        '.RynTarotBackup_20260717T010203Z_a1b2c3d4.rynbackup'
        '.partial-a1b2c3d4',
      ),
    );
    await names.finalDirectory.create();
    expect(
      () => resolved.requireNoCollision(names),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(
      () => resolved.packagePaths(
        createdAtUtc: DateTime.now(),
        operationId: 'UPPER123',
      ),
      throwsA(isA<TarotBackupPathException>()),
    );
  });

  test('path comparisons are case-insensitive and reject overlap', () {
    expect(
      () => TarotBackupPathContract(
        sourceRootPath: sourceRoot.path,
        backupRootPath: sourceRoot.path.toUpperCase(),
        protectedRootPaths: const <String>[],
        inspectPath: (_) async => true,
      ).resolve(),
      throwsA(isA<TarotBackupPathException>()),
    );
  });

  test('reparse inspection is performed each time and never cached', () async {
    final resolved = contract().resolve();
    await resolved.requireSafeAncestry(backupRoot.path);
    await resolved.requireSafeAncestry(backupRoot.path);

    expect(inspections, <String>[backupRoot.path, backupRoot.path]);
  });
}
