import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/backup_recovery/sha256_digest_service.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_database_inspector.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_sqlite_online_backup_service.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  late TarotBackupRecoveryFixture fixture;
  const inspector = TarotBackupDatabaseInspector();

  tearDown(() async {
    await fixture.dispose();
  });

  test('inspector accepts schema 5 and valid structural aggregate', () async {
    fixture = await TarotBackupRecoveryFixture.create();

    final evidence = inspector.inspect(
      fixture.sourceFile.path,
      policy: TarotDatabaseInspectionPolicy.normalReadOnlySource,
    );

    expect(evidence.schemaVersion, 5);
    expect(evidence.requiredTablesPresent, isTrue);
    expect(evidence.requiredColumnsPresent, isTrue);
    expect(evidence.integrityCheckOk, isTrue);
    expect(evidence.foreignKeyCheckOk, isTrue);
    expect(evidence.aggregateInvariantsOk, isTrue);
    expect(evidence.unsupportedTableRowsZero, isTrue);
    expect(evidence.readingRowCount, 1);
    expect(evidence.placementCount, 3);
    expect(evidence.interpretationCount, 1);
    expect(evidence.runtimeStateRowCount, 1);
  });

  test('inspector safely rejects missing table and missing column', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    var db = fixture.openSource();
    db.execute('DROP TABLE tarot_interpretations');
    fixture.release(db);
    expect(
      () => _inspectSource(inspector, fixture.sourceFile.path),
      throwsA(
        isA<TarotBackupInspectionException>().having(
          (error) => error.code,
          'code',
          'required_table_missing',
        ),
      ),
    );

    await fixture.dispose();
    fixture = await TarotBackupRecoveryFixture.create();
    db = fixture.openSource();
    db.execute('ALTER TABLE app_settings RENAME TO app_settings_old');
    db.execute('CREATE TABLE app_settings (key TEXT PRIMARY KEY)');
    db.execute('DROP TABLE app_settings_old');
    fixture.release(db);
    expect(
      () => _inspectSource(inspector, fixture.sourceFile.path),
      throwsA(
        isA<TarotBackupInspectionException>().having(
          (error) => error.code,
          'code',
          'required_column_missing',
        ),
      ),
    );
  });

  test('inspector rejects undeclared tables and extra columns', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    var db = fixture.openSource();
    db.execute(
      'CREATE TABLE undeclared_private_rows '
      '(id TEXT PRIMARY KEY, private_text TEXT NOT NULL)',
    );
    db.execute(
      "INSERT INTO undeclared_private_rows VALUES ('synthetic', 'private')",
    );
    fixture.release(db);
    expect(
      () => _inspectSource(inspector, fixture.sourceFile.path),
      throwsA(
        isA<TarotBackupInspectionException>().having(
          (error) => error.code,
          'code',
          'unexpected_table_present',
        ),
      ),
    );

    await fixture.dispose();
    fixture = await TarotBackupRecoveryFixture.create();
    db = fixture.openSource();
    db.execute('ALTER TABLE app_settings ADD COLUMN private_text TEXT');
    fixture.release(db);
    expect(
      () => _inspectSource(inspector, fixture.sourceFile.path),
      throwsA(
        isA<TarotBackupInspectionException>().having(
          (error) => error.code,
          'code',
          'unexpected_column_present',
        ),
      ),
    );
  });

  test(
    'aggregate gap orientation orphan and active Home failures are rejected',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      var db = fixture.openSource();
      db.execute(
        "UPDATE tarot_card_placements SET placement_order = 4 "
        "WHERE reading_instance_id = 'synthetic-r1' AND placement_order = 3",
      );
      fixture.release(db);
      expect(
        () => _inspectSource(inspector, fixture.sourceFile.path),
        throwsA(isA<TarotBackupInspectionException>()),
      );

      await fixture.dispose();
      fixture = await TarotBackupRecoveryFixture.create();
      db = fixture.openSource();
      db.execute('PRAGMA ignore_check_constraints = ON');
      db.execute("UPDATE tarot_card_placements SET orientation = 'sideways'");
      fixture.release(db);
      expect(
        () => _inspectSource(inspector, fixture.sourceFile.path),
        throwsA(isA<TarotBackupInspectionException>()),
      );

      await fixture.dispose();
      fixture = await TarotBackupRecoveryFixture.create();
      db = fixture.openSource();
      db.execute('PRAGMA foreign_keys = OFF');
      db.execute(
        "UPDATE tarot_interpretations SET reading_instance_id = 'orphan'",
      );
      fixture.release(db);
      expect(
        () => _inspectSource(inspector, fixture.sourceFile.path),
        throwsA(isA<TarotBackupInspectionException>()),
      );

      await fixture.dispose();
      fixture = await TarotBackupRecoveryFixture.create();
      db = fixture.openSource();
      db.execute('PRAGMA foreign_keys = OFF');
      db.execute(
        "UPDATE app_runtime_state SET active_home_tarot_reading_id = 'missing'",
      );
      fixture.release(db);
      expect(
        () => _inspectSource(inspector, fixture.sourceFile.path),
        throwsA(isA<TarotBackupInspectionException>()),
      );
    },
  );

  test('unsupported application rows fail without exposing row values', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final db = fixture.openSource();
    db.execute(
      "INSERT INTO app_settings (key, value, value_type, redaction_state, updated_at) "
      "VALUES ('SYNTHETIC_PRIVATE_VALUE', NULL, 'string', 'none_required', 0)",
    );
    fixture.release(db);

    expect(
      () => _inspectSource(inspector, fixture.sourceFile.path),
      throwsA(
        isA<TarotBackupInspectionException>()
            .having((error) => error.code, 'code', 'unsupported_table_nonzero')
            .having(
              (error) => error.toString(),
              'safe message',
              isNot(contains('SYNTHETIC_PRIVATE_VALUE')),
            ),
      ),
    );
  });

  test(
    'inspection policies separate live source from immutable target URI',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final opens = <({String filename, OpenMode mode, bool uri})>[];
      final trackingInspector = TarotBackupDatabaseInspector(
        openDatabase: (filename, mode, uri) {
          opens.add((filename: filename, mode: mode, uri: uri));
          return sqlite3.open(filename, mode: mode, uri: uri);
        },
      );

      trackingInspector.inspectVerified(
        fixture.sourceFile.path,
        policy: TarotDatabaseInspectionPolicy.normalReadOnlySource,
      );

      expect(opens, hasLength(1));
      expect(opens.single.filename, fixture.sourceFile.path);
      expect(opens.single.mode, OpenMode.readOnly);
      expect(opens.single.uri, isFalse);
      expect(opens.single.filename, isNot(contains('immutable=')));

      const syntheticWindowsPath =
          r'C:\Synthetic Folder\#percent%한글\target.sqlite';
      expect(
        () => Uri.file(
          r'C:\Synthetic Folder\question?mark\target.sqlite',
          windows: true,
        ),
        throwsArgumentError,
      );
      String? immutableFilename;
      OpenMode? immutableMode;
      bool? immutableUri;
      final capturingInspector = TarotBackupDatabaseInspector(
        openDatabase: (filename, mode, uri) {
          immutableFilename = filename;
          immutableMode = mode;
          immutableUri = uri;
          throw StateError('capture only');
        },
      );

      expect(
        () => capturingInspector.inspect(
          syntheticWindowsPath,
          policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
        ),
        throwsA(isA<TarotBackupInspectionException>()),
      );
      final parsed = Uri.parse(immutableFilename!);
      final decodedPath = Uri(
        scheme: parsed.scheme,
        host: parsed.host,
        path: parsed.path,
      ).toFilePath(windows: true);
      expect(immutableMode, OpenMode.readOnly);
      expect(immutableUri, isTrue);
      expect(immutableFilename, startsWith('file:///C:/'));
      expect(parsed.queryParametersAll, <String, List<String>>{
        'mode': <String>['ro'],
        'immutable': <String>['1'],
      });
      expect(decodedPath, syntheticWindowsPath);
      expect(immutableFilename, contains('Synthetic%20Folder'));
      expect(immutableFilename, contains('%23percent%25'));
      expect(immutableFilename, contains('%ED%95%9C%EA%B8%80'));
    },
  );

  test(
    'unsafe sidecar blocks immutable target open and is not deleted',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final target = File(
        '${fixture.backupRoot.path}${Platform.pathSeparator}immutable-pre-open'
        '${Platform.pathSeparator}target.sqlite',
      );
      await target.parent.create();
      final sidecar = File('${target.path}-wal');
      var immutableTargetOpenCount = 0;
      var unsafeSidecarDeleteCount = 0;
      final trackingInspector = TarotBackupDatabaseInspector(
        openDatabase: (filename, mode, uri) {
          if (uri) immutableTargetOpenCount += 1;
          return sqlite3.open(filename, mode: mode, uri: uri);
        },
      );
      final service = TarotSqliteOnlineBackupService(
        inspector: trackingInspector,
        afterOnlineBackupBeforeVerification: () async {
          await sidecar.writeAsBytes(<int>[1], flush: true);
        },
        deleteFile: (file) async {
          if (file.path == sidecar.path) unsafeSidecarDeleteCount += 1;
          await file.delete();
        },
      );

      await expectLater(
        service.createSnapshot(
          sourceDatabasePath: fixture.sourceFile.path,
          targetDatabasePath: target.path,
          paths: fixture.resolvedPaths(),
        ),
        throwsA(isA<TarotSqliteBackupException>()),
      );
      expect(immutableTargetOpenCount, 0);
      expect(unsafeSidecarDeleteCount, 0);
      expect(sidecar.readAsBytesSync(), <int>[1]);
    },
  );

  test('post-close created sidecar rejects immutable target result', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}immutable-post-close'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    final sidecar = File('${target.path}-shm');
    var inspectorCloseAttempts = 0;
    var immutableTargetOpenCount = 0;
    var unsafeSidecarDeleteCount = 0;
    var returnedResult = false;
    final trackingInspector = TarotBackupDatabaseInspector(
      openDatabase: (filename, mode, uri) {
        if (uri) immutableTargetOpenCount += 1;
        return sqlite3.open(filename, mode: mode, uri: uri);
      },
      closeDatabase: (database) {
        inspectorCloseAttempts += 1;
        database.close();
        if (inspectorCloseAttempts == 2) {
          sidecar.writeAsBytesSync(<int>[7], flush: true);
        }
      },
    );
    final service = TarotSqliteOnlineBackupService(
      inspector: trackingInspector,
      deleteFile: (file) async {
        if (file.path == sidecar.path) unsafeSidecarDeleteCount += 1;
        await file.delete();
      },
    );

    await expectLater(
      service
          .createSnapshot(
            sourceDatabasePath: fixture.sourceFile.path,
            targetDatabasePath: target.path,
            paths: fixture.resolvedPaths(),
          )
          .then((result) {
            returnedResult = true;
            return result;
          }),
      throwsA(
        isA<TarotBackupInspectionException>().having(
          (error) => error.code,
          'code',
          'target_sidecar_unsafe',
        ),
      ),
    );
    expect(inspectorCloseAttempts, 2);
    expect(immutableTargetOpenCount, 1);
    expect(unsafeSidecarDeleteCount, 0);
    expect(sidecar.readAsBytesSync(), <int>[7]);
    expect(returnedResult, isFalse);
  });

  test(
    'Online Backup includes committed WAL data and source stays usable',
    () async {
      fixture = await TarotBackupRecoveryFixture.create(walMode: true);
      final writer = fixture.openSource();
      writer.execute('PRAGMA journal_mode = WAL');
      fixture.insertValidReading(writer, id: 'synthetic-committed');
      final before = fixture.logicalEvidence(writer);
      final sourceSizeBefore = fixture.sourceFile.lengthSync();
      final sourceHashBefore = await const DartSha256DigestService().digestFile(
        fixture.sourceFile,
      );
      final target = File(
        '${fixture.backupRoot.path}${Platform.pathSeparator}operation'
        '${Platform.pathSeparator}target.sqlite',
      );
      await target.parent.create();

      final result = await const TarotSqliteOnlineBackupService()
          .createSnapshot(
            sourceDatabasePath: fixture.sourceFile.path,
            targetDatabasePath: target.path,
            paths: fixture.resolvedPaths(),
          );

      final sourceAfter = fixture.logicalEvidence(writer);
      final sourceHashAfter = await const DartSha256DigestService().digestFile(
        fixture.sourceFile,
      );
      final targetDb = sqlite3.open(target.path, mode: OpenMode.readOnly);
      final targetEvidence = fixture.logicalEvidence(targetDb);
      targetDb.close();
      expect(targetEvidence['readingCount'], 2);
      expect(sourceAfter, before);
      expect(fixture.sourceFile.lengthSync(), sourceSizeBefore);
      expect(sourceHashAfter, sourceHashBefore);
      expect(result.afterSanitation.freelistCount, 0);
      expect(
        result.beforeSanitation.sameLogicalState(result.afterSanitation),
        isTrue,
      );
      expect(result.afterSanitation.hasUnexpectedNonEmptySidecar, isFalse);
      expect(writer.select('SELECT 1').single.values.single, 1);
      fixture.release(writer);
    },
  );

  test(
    'target-only VACUUM clears freelist without changing logical state',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final writer = fixture.openSource();
      writer.execute('BEGIN');
      for (var index = 0; index < 160; index++) {
        fixture.insertValidReading(writer, id: 'synthetic-deleted-$index');
      }
      writer.execute(
        "DELETE FROM tarot_interpretations "
        "WHERE reading_instance_id LIKE 'synthetic-deleted-%'",
      );
      writer.execute(
        "DELETE FROM tarot_card_placements "
        "WHERE reading_instance_id LIKE 'synthetic-deleted-%'",
      );
      writer.execute(
        "DELETE FROM tarot_readings "
        "WHERE reading_instance_id LIKE 'synthetic-deleted-%'",
      );
      writer.execute(
        "UPDATE app_runtime_state SET active_home_tarot_reading_id = 'synthetic-r1' "
        "WHERE state_key = 'main'",
      );
      writer.execute('COMMIT');
      expect(
        writer.select('PRAGMA freelist_count').single.values.single,
        greaterThan(0),
      );
      final sourceEvidenceBefore = fixture.logicalEvidence(writer);
      final target = File(
        '${fixture.backupRoot.path}${Platform.pathSeparator}vacuum-operation'
        '${Platform.pathSeparator}target.sqlite',
      );
      await target.parent.create();

      final result = await const TarotSqliteOnlineBackupService()
          .createSnapshot(
            sourceDatabasePath: fixture.sourceFile.path,
            targetDatabasePath: target.path,
            paths: fixture.resolvedPaths(),
          );

      expect(result.beforeSanitation.freelistCount, greaterThan(0));
      expect(result.afterSanitation.freelistCount, 0);
      expect(
        result.beforeSanitation.sameLogicalState(result.afterSanitation),
        isTrue,
      );
      expect(fixture.logicalEvidence(writer), sourceEvidenceBefore);
      expect(
        writer.select('PRAGMA freelist_count').single.values.single,
        greaterThan(0),
      );
      fixture.release(writer);
    },
  );

  test('Online Backup excludes an uncommitted writer transaction', () async {
    fixture = await TarotBackupRecoveryFixture.create(walMode: true);
    final writer = fixture.openSource();
    writer.execute('PRAGMA journal_mode = WAL');
    writer.execute('BEGIN IMMEDIATE');
    fixture.insertValidReading(writer, id: 'synthetic-uncommitted');
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}operation'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();

    await const TarotSqliteOnlineBackupService().createSnapshot(
      sourceDatabasePath: fixture.sourceFile.path,
      targetDatabasePath: target.path,
      paths: fixture.resolvedPaths(),
    );

    final targetDb = sqlite3.open(target.path, mode: OpenMode.readOnly);
    expect(fixture.logicalEvidence(targetDb)['readingCount'], 1);
    targetDb.close();
    writer.execute('ROLLBACK');
    fixture.release(writer);
  });

  test('deadline failure closes handles and removes invalid target', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}operation'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    final service = TarotSqliteOnlineBackupService(
      onlineBackup: (_, _, _) => Completer<void>().future,
    );

    await expectLater(
      service.createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(),
        deadline: const Duration(milliseconds: 20),
      ),
      throwsA(
        isA<TarotSqliteBackupException>().having(
          (error) => error.code,
          'code',
          'snapshot_timeout',
        ),
      ),
    );
    expect(target.existsSync(), isFalse);
    final source = fixture.openSource(mode: OpenMode.readOnly);
    expect(source.select('SELECT 1').single.values.single, 1);
    fixture.release(source);
  });

  test(
    'native Online Backup timeout finishes and releases locked source',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      var setup = fixture.openSource();
      setup.select('PRAGMA journal_mode = DELETE');
      fixture.release(setup);
      final target = File(
        '${fixture.backupRoot.path}${Platform.pathSeparator}operation-native'
        '${Platform.pathSeparator}target.sqlite',
      );
      await target.parent.create();
      Database? writer;
      final service = TarotSqliteOnlineBackupService(
        beforeOnlineBackup: () async {
          writer = fixture.openSource();
          writer!.execute('BEGIN EXCLUSIVE');
        },
      );

      await expectLater(
        service.createSnapshot(
          sourceDatabasePath: fixture.sourceFile.path,
          targetDatabasePath: target.path,
          paths: fixture.resolvedPaths(),
          deadline: const Duration(milliseconds: 40),
        ),
        throwsA(
          isA<TarotSqliteBackupException>().having(
            (error) => error.code,
            'code',
            'snapshot_timeout',
          ),
        ),
      );
      writer!.execute('ROLLBACK');
      fixture.release(writer!);
      expect(target.existsSync(), isFalse);
      final renamed = await fixture.sourceFile.rename(
        '${fixture.sourceFile.path}.native-moved',
      );
      await renamed.rename(fixture.sourceFile.path);
    },
  );

  test('source reparse inspection fails before any database open', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}operation'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    final inspected = <String>[];

    await expectLater(
      const TarotSqliteOnlineBackupService().createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(
          inspectPath: (path) async {
            inspected.add(path);
            return path != fixture.sourceFile.path;
          },
        ),
      ),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(inspected, contains(fixture.sourceFile.path));
    expect(target.existsSync(), isFalse);
  });

  test('target-open failure still releases the source connection', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final invalidTarget = await Directory(
      '${fixture.backupRoot.path}${Platform.pathSeparator}directory-as-target',
    ).create();

    await expectLater(
      const TarotSqliteOnlineBackupService().createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: invalidTarget.path,
        paths: fixture.resolvedPaths(),
      ),
      throwsA(isA<TarotSqliteBackupException>()),
    );
    final renamed = await fixture.sourceFile.rename(
      '${fixture.sourceFile.path}.moved',
    );
    await renamed.rename(fixture.sourceFile.path);
    expect(fixture.sourceFile.existsSync(), isTrue);
  });

  test('target is rechecked after backup before sanitation', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}post-backup'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    var unsafe = false;
    final service = TarotSqliteOnlineBackupService(
      afterOnlineBackupBeforeVerification: () async => unsafe = true,
    );

    await expectLater(
      service.createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(inspectPath: (_) async => !unsafe),
      ),
      throwsA(isA<TarotSqliteBackupException>()),
    );
  });

  test('unsafe failed target is preserved instead of deleted', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}failed-cleanup'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    var unsafe = false;
    final service = TarotSqliteOnlineBackupService(
      beforeOnlineBackup: () async => throw StateError('synthetic'),
      beforeFailedTargetCleanup: () async => unsafe = true,
    );

    await expectLater(
      service.createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(inspectPath: (_) async => !unsafe),
      ),
      throwsA(isA<TarotSqliteBackupException>()),
    );
    expect(target.existsSync(), isTrue);
  });

  test(
    'backup connection close failures attempt both closes and skip cleanup',
    () async {
      for (final failingRoles in <Set<String>>[
        <String>{'backup_target'},
        <String>{'source'},
        <String>{'backup_target', 'source'},
      ]) {
        fixture = await TarotBackupRecoveryFixture.create();
        final target = File(
          '${fixture.backupRoot.path}${Platform.pathSeparator}close-failure'
          '${Platform.pathSeparator}target.sqlite',
        );
        await target.parent.create();
        final closeAttempts = <String, int>{};
        var cleanupCount = 0;
        var returnedResult = false;
        final service = TarotSqliteOnlineBackupService(
          onlineBackup: (_, _, _) async {},
          databaseClose: (database, role) {
            closeAttempts[role] = (closeAttempts[role] ?? 0) + 1;
            database.close();
            if (failingRoles.contains(role)) {
              throw StateError('synthetic close failure');
            }
          },
          beforeFailedTargetCleanup: () async => cleanupCount += 1,
        );

        await expectLater(
          service
              .createSnapshot(
                sourceDatabasePath: fixture.sourceFile.path,
                targetDatabasePath: target.path,
                paths: fixture.resolvedPaths(),
              )
              .then((result) {
                returnedResult = true;
                return result;
              }),
          throwsA(isA<TarotSqliteBackupException>()),
        );
        expect(closeAttempts['backup_target'], 1);
        expect(closeAttempts['source'], 1);
        expect(cleanupCount, 0);
        expect(returnedResult, isFalse);
        expect(target.existsSync(), isTrue);
        await fixture.dispose();
      }
    },
  );

  test('sanitation close failure blocks cleanup and success', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}sanitation-close'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    var sanitationCloseAttempts = 0;
    var cleanupCount = 0;
    var returnedResult = false;
    final service = TarotSqliteOnlineBackupService(
      databaseClose: (database, role) {
        database.close();
        if (role == 'sanitation') {
          sanitationCloseAttempts += 1;
          throw StateError('synthetic sanitation close failure');
        }
      },
      beforeFailedTargetCleanup: () async => cleanupCount += 1,
    );

    await expectLater(
      service
          .createSnapshot(
            sourceDatabasePath: fixture.sourceFile.path,
            targetDatabasePath: target.path,
            paths: fixture.resolvedPaths(),
          )
          .then((result) {
            returnedResult = true;
            return result;
          }),
      throwsA(isA<TarotSqliteBackupException>()),
    );
    expect(sanitationCloseAttempts, 1);
    expect(cleanupCount, 0);
    expect(returnedResult, isFalse);
    expect(target.existsSync(), isTrue);
  });

  test(
    'inspector close failure is structural and blocks target cleanup',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final target = File(
        '${fixture.backupRoot.path}${Platform.pathSeparator}inspector-close'
        '${Platform.pathSeparator}target.sqlite',
      );
      await target.parent.create();
      var inspectorCloseAttempts = 0;
      var cleanupCount = 0;
      final inspector = TarotBackupDatabaseInspector(
        closeDatabase: (database) {
          inspectorCloseAttempts += 1;
          database.close();
          if (inspectorCloseAttempts == 2) {
            throw StateError('synthetic inspector close failure');
          }
        },
      );
      final service = TarotSqliteOnlineBackupService(
        inspector: inspector,
        beforeFailedTargetCleanup: () async => cleanupCount += 1,
      );

      await expectLater(
        service.createSnapshot(
          sourceDatabasePath: fixture.sourceFile.path,
          targetDatabasePath: target.path,
          paths: fixture.resolvedPaths(),
        ),
        throwsA(
          isA<TarotBackupInspectionException>().having(
            (error) => error.code,
            'code',
            'database_close_failed',
          ),
        ),
      );
      expect(inspectorCloseAttempts, 2);
      expect(cleanupCount, 0);
      expect(target.existsSync(), isTrue);
    },
  );

  test(
    'unsafe sidecar before initial target open blocks writable open',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final target = File(
        '${fixture.backupRoot.path}${Platform.pathSeparator}initial-sidecar'
        '${Platform.pathSeparator}target.sqlite',
      );
      await target.parent.create();
      final external = await Directory(
        '${fixture.root.path}${Platform.pathSeparator}external-initial',
      ).create();
      final sentinel = File('${external.path}${Platform.pathSeparator}sentinel')
        ..writeAsStringSync('keep');
      final sidecar = Directory('${target.path}-journal');
      await _createJunction(sidecar.path, external.path);
      var writableTargetOpenCount = 0;
      var returnedResult = false;
      final service = TarotSqliteOnlineBackupService(
        databaseOpen: (path, mode, role) {
          if (role == 'backup_target') writableTargetOpenCount += 1;
          return sqlite3.open(path, mode: mode);
        },
      );

      await expectLater(
        service
            .createSnapshot(
              sourceDatabasePath: fixture.sourceFile.path,
              targetDatabasePath: target.path,
              paths: fixture.resolvedPaths(),
            )
            .then((result) {
              returnedResult = true;
              return result;
            }),
        throwsA(isA<TarotSqliteBackupException>()),
      );
      expect(writableTargetOpenCount, 0);
      expect(sentinel.readAsStringSync(), 'keep');
      expect(returnedResult, isFalse);
      expect(sidecar.existsSync(), isTrue);
      await sidecar.delete();
    },
  );

  test('unsafe sidecar swap blocks sanitation open and vacuum', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final sourceBefore = _inspectSource(inspector, fixture.sourceFile.path);
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}sanitation-sidecar'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    final external = await Directory(
      '${fixture.root.path}${Platform.pathSeparator}external-sanitation',
    ).create();
    final sentinel = File('${external.path}${Platform.pathSeparator}sentinel')
      ..writeAsStringSync('keep');
    final sidecar = Directory('${target.path}-journal');
    var sanitationOpenCount = 0;
    var vacuumCount = 0;
    final service = TarotSqliteOnlineBackupService(
      afterOnlineBackupBeforeVerification: () async {
        await _createJunction(sidecar.path, external.path);
      },
      databaseOpen: (path, mode, role) {
        if (role == 'sanitation') sanitationOpenCount += 1;
        return sqlite3.open(path, mode: mode);
      },
      beforeTargetVacuum: () async => vacuumCount += 1,
    );

    await expectLater(
      service.createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(),
      ),
      throwsA(isA<TarotSqliteBackupException>()),
    );
    expect(sanitationOpenCount, 0);
    expect(vacuumCount, 0);
    expect(sentinel.readAsStringSync(), 'keep');
    expect(
      sourceBefore.sameLogicalState(
        _inspectSource(inspector, fixture.sourceFile.path),
      ),
      isTrue,
    );
    expect(sidecar.existsSync(), isTrue);
    await sidecar.delete();
  });

  test('unsafe sidecar swap blocks post-sanitation inspector open', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}post-sidecar'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    final external = await Directory(
      '${fixture.root.path}${Platform.pathSeparator}external-post',
    ).create();
    final sentinel = File('${external.path}${Platform.pathSeparator}sentinel')
      ..writeAsStringSync('keep');
    final sidecar = Directory('${target.path}-journal');
    var unsafe = false;
    var postInspectorOpenCount = 0;
    final trackingInspector = TarotBackupDatabaseInspector(
      openDatabase: (filename, mode, uri) {
        if (unsafe && uri) postInspectorOpenCount += 1;
        return sqlite3.open(filename, mode: mode, uri: uri);
      },
    );
    final service = TarotSqliteOnlineBackupService(
      inspector: trackingInspector,
      beforePostSanitationInspection: () async {
        await _createJunction(sidecar.path, external.path);
        unsafe = true;
      },
    );

    await expectLater(
      service.createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(),
      ),
      throwsA(isA<TarotSqliteBackupException>()),
    );
    expect(postInspectorOpenCount, 0);
    expect(sentinel.readAsStringSync(), 'keep');
    expect(sidecar.existsSync(), isTrue);
    await sidecar.delete();
  });

  test('suspect sidecar is preserved during failed-target cleanup', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final target = File(
      '${fixture.backupRoot.path}${Platform.pathSeparator}cleanup-sidecar'
      '${Platform.pathSeparator}target.sqlite',
    );
    await target.parent.create();
    final external = await Directory(
      '${fixture.root.path}${Platform.pathSeparator}external-cleanup',
    ).create();
    final sentinel = File('${external.path}${Platform.pathSeparator}sentinel')
      ..writeAsStringSync('keep');
    final sidecar = Directory('${target.path}-journal');
    var unsafeSidecarDeleteCount = 0;
    final service = TarotSqliteOnlineBackupService(
      beforeOnlineBackup: () async {
        await _createJunction(sidecar.path, external.path);
        throw StateError('synthetic backup failure');
      },
      deleteFile: (file) async {
        if (file.path == sidecar.path) unsafeSidecarDeleteCount += 1;
        await file.delete();
      },
    );

    await expectLater(
      service.createSnapshot(
        sourceDatabasePath: fixture.sourceFile.path,
        targetDatabasePath: target.path,
        paths: fixture.resolvedPaths(),
      ),
      throwsA(isA<TarotSqliteBackupException>()),
    );
    expect(unsafeSidecarDeleteCount, 0);
    expect(sentinel.readAsStringSync(), 'keep');
    expect(sidecar.existsSync(), isTrue);
    await sidecar.delete();
  });

  test(
    'zero-byte sidecar is allowed only after backup and nonzero is rejected',
    () async {
      for (final sidecarBytes in <List<int>>[
        <int>[],
        <int>[1],
      ]) {
        fixture = await TarotBackupRecoveryFixture.create();
        final target = File(
          '${fixture.backupRoot.path}${Platform.pathSeparator}regular-sidecar'
          '${Platform.pathSeparator}target.sqlite',
        );
        await target.parent.create();
        final sidecar = File('${target.path}-journal');
        final service = TarotSqliteOnlineBackupService(
          afterOnlineBackupBeforeVerification: () async {
            await sidecar.writeAsBytes(sidecarBytes, flush: true);
          },
        );

        if (sidecarBytes.isEmpty) {
          final result = await service.createSnapshot(
            sourceDatabasePath: fixture.sourceFile.path,
            targetDatabasePath: target.path,
            paths: fixture.resolvedPaths(),
          );
          expect(result.afterSanitation.hasUnexpectedNonEmptySidecar, isFalse);
        } else {
          await expectLater(
            service.createSnapshot(
              sourceDatabasePath: fixture.sourceFile.path,
              targetDatabasePath: target.path,
              paths: fixture.resolvedPaths(),
            ),
            throwsA(isA<TarotSqliteBackupException>()),
          );
        }
        await fixture.dispose();
      }
    },
  );

  test(
    'sidecar directory and unsafe ancestry fail before writable target open',
    () async {
      for (final useUnsafeInspection in <bool>[false, true]) {
        fixture = await TarotBackupRecoveryFixture.create();
        final target = File(
          '${fixture.backupRoot.path}${Platform.pathSeparator}sidecar-type'
          '${Platform.pathSeparator}target.sqlite',
        );
        await target.parent.create();
        final sidecar = Directory('${target.path}-wal');
        if (!useUnsafeInspection) await sidecar.create();
        var writableTargetOpenCount = 0;
        final service = TarotSqliteOnlineBackupService(
          databaseOpen: (path, mode, role) {
            if (role == 'backup_target') writableTargetOpenCount += 1;
            return sqlite3.open(path, mode: mode);
          },
        );

        await expectLater(
          service.createSnapshot(
            sourceDatabasePath: fixture.sourceFile.path,
            targetDatabasePath: target.path,
            paths: fixture.resolvedPaths(
              inspectPath: (path) async =>
                  !useUnsafeInspection || path != sidecar.path,
            ),
          ),
          throwsA(isA<TarotSqliteBackupException>()),
        );
        expect(writableTargetOpenCount, 0);
        await fixture.dispose();
      }
    },
  );
}

TarotDatabaseEvidence _inspectSource(
  TarotBackupDatabaseInspector inspector,
  String path,
) => inspector.inspectVerified(
  path,
  policy: TarotDatabaseInspectionPolicy.normalReadOnlySource,
);

Future<void> _createJunction(String junctionPath, String targetPath) async {
  final result = await Process.run('cmd', <String>[
    '/c',
    'mklink',
    '/J',
    junctionPath,
    targetPath,
  ]);
  if (result.exitCode != 0) {
    throw StateError('synthetic_junction_creation_failed');
  }
}
