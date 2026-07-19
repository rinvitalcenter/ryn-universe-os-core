import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/application/tarot_runtime_controller.dart';
import 'package:ryn_universe_os_core/core/persistence/runtime_data_profile.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_backup_restore_action_controller.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_restore_startup_recovery_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_restore_candidate.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_restore_operation_result.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_restore_candidate_validator.dart';

import 'package:ryn_universe_os_core/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TarotRestoreCandidate candidate() => TarotRestoreCandidate(
    packagePath: 'C:/Temp/RynTarotBackup_20260717T020304Z_deadbeef.rynbackup',
    snapshotPath: 'C:/Temp/snapshot.sqlite',
    createdAtUtc: DateTime.utc(2026, 7, 17, 2, 3, 4),
    operationId: 'deadbeef',
    backupFormatVersion: 1,
    schemaVersion: 6,
    snapshotSha256: 'a' * 64,
    snapshotSizeBytes: 4096,
  );

  Future<void> openSettings(
    WidgetTester tester,
    TarotBackupRestoreActionController actions,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RynUniverseApp(
        runtimeController: TarotRuntimeController.presentationTest(),
        backupRestoreController: actions,
        bootstrapOnStart: false,
      ),
    );
    await tester.tap(find.text('설정').first);
    await tester.pumpAndSettle();
  }

  testWidgets('data safety exposes buttons progress success and backup path', (
    tester,
  ) async {
    final completion = Completer<String>();
    final actions = TarotBackupRestoreActionController(
      createBackup: () => completion.future,
      selectRestoreDirectory: () async => null,
      validateRestoreCandidate: (_) async => candidate(),
      restore: (_) async => const TarotRestoreOperationResult.succeeded(
        safetyBackupPackagePath: 'C:/Temp/safety.rynbackup',
        preservedEvidencePath: 'C:/Temp/evidence',
      ),
    );
    addTearDown(actions.dispose);
    await openSettings(tester, actions);

    expect(find.text('데이터 안전'), findsOneWidget);
    expect(find.text('백업 만들기'), findsOneWidget);
    expect(find.text('백업에서 복원'), findsOneWidget);

    await tester.tap(find.byKey(const Key('data-safety-backup')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final backupButton = tester.widget<FilledButton>(
      find.byKey(const Key('data-safety-backup')),
    );
    final restoreButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('data-safety-restore')),
    );
    expect(backupButton.onPressed, isNull);
    expect(restoreButton.onPressed, isNull);

    completion.complete('C:/Temp/RynTarotBackup_test.rynbackup');
    await tester.pumpAndSettle();
    expect(find.text('백업을 만들었어요.'), findsOneWidget);
    expect(find.text('C:/Temp/RynTarotBackup_test.rynbackup'), findsOneWidget);
  });

  testWidgets('validated restore requires warning confirmation then succeeds', (
    tester,
  ) async {
    var restoreCount = 0;
    final actions = TarotBackupRestoreActionController(
      createBackup: () async => 'C:/Temp/backup.rynbackup',
      selectRestoreDirectory: () async => candidate().packagePath,
      validateRestoreCandidate: (_) async => candidate(),
      restore: (_) async {
        restoreCount += 1;
        return const TarotRestoreOperationResult.succeeded(
          safetyBackupPackagePath: 'C:/Temp/safety.rynbackup',
          preservedEvidencePath: 'C:/Temp/evidence',
        );
      },
    );
    addTearDown(actions.dispose);
    await openSettings(tester, actions);

    await tester.tap(find.byKey(const Key('data-safety-restore')));
    await tester.pumpAndSettle();

    expect(find.text('백업에서 복원'), findsWidgets);
    expect(find.text('현재 데이터는 자동 안전 백업된 후 선택한 백업으로 교체됩니다.'), findsOneWidget);
    expect(find.text('복원 중에는 앱을 종료하지 마세요.'), findsOneWidget);
    expect(restoreCount, 0);

    await tester.tap(find.byKey(const Key('restore-confirm')));
    await tester.pumpAndSettle();
    expect(restoreCount, 1);
    expect(find.text('백업에서 복원했어요.'), findsOneWidget);
    expect(find.text('C:/Temp/safety.rynbackup'), findsOneWidget);
  });

  testWidgets('candidate validation failure returns buttons to usable state', (
    tester,
  ) async {
    final actions = TarotBackupRestoreActionController(
      createBackup: () async => 'C:/Temp/backup.rynbackup',
      selectRestoreDirectory: () async => 'C:/Temp/broken.rynbackup',
      validateRestoreCandidate: (_) async => throw StateError('invalid'),
      restore: (_) async => throw StateError('must not run'),
    );
    addTearDown(actions.dispose);
    await openSettings(tester, actions);

    await tester.tap(find.byKey(const Key('data-safety-restore')));
    await tester.pumpAndSettle();

    expect(find.text('선택한 백업을 확인하지 못했어요.'), findsOneWidget);
    final backupButton = tester.widget<FilledButton>(
      find.byKey(const Key('data-safety-backup')),
    );
    expect(backupButton.onPressed, isNotNull);
  });

  testWidgets('fatal restore shows explicit recovery-required guidance', (
    tester,
  ) async {
    final actions = TarotBackupRestoreActionController(
      createBackup: () async => 'C:/Temp/backup.rynbackup',
      selectRestoreDirectory: () async => candidate().packagePath,
      validateRestoreCandidate: (_) async => candidate(),
      restore: (_) async =>
          const TarotRestoreOperationResult.fatalRecoveryRequired(
            failureCode: 'rollback_failed',
            safetyBackupPackagePath: 'C:/Temp/safety.rynbackup',
            preservedEvidencePath: 'C:/Temp/evidence',
          ),
    );
    addTearDown(actions.dispose);
    await openSettings(tester, actions);

    await tester.tap(find.byKey(const Key('data-safety-restore')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('restore-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('복구 필요'), findsOneWidget);
    expect(find.text('자동 복구를 완료하지 못했어요. 보존된 복구 자료가 필요합니다.'), findsOneWidget);
    expect(find.text('C:/Temp/evidence'), findsOneWidget);
  });

  test(
    'synthetic action controller completes real backup and restore loop',
    () async {
      final root = await Directory.systemTemp.createTemp('ryn-backup-ui-loop-');
      final pathContract = RynRuntimeDataPathContract.forApplicationSupportRoot(
        root,
      );
      final validator = TarotRestoreCandidateValidator();
      final runtime = TarotRuntimeController.development(
        pathContract: pathContract,
        runtimeDataMode: RynRuntimeDataMode.tarotBackupRecoveryQa,
        startupRecoveryCoordinator: TarotRestoreStartupRecoveryCoordinator(
          candidateValidator: validator,
        ),
      );
      String? selectedPackage;
      final actions = TarotBackupRestoreActionController.synthetic(
        runtimeController: runtime,
        pathContract: pathContract,
        selectRestoreDirectory: () async => selectedPackage,
      );
      try {
        await runtime.bootstrap();
        expect(runtime.startupStatus, TarotRuntimeStartupStatus.readyEmpty);

        await actions.createBackup();
        selectedPackage = actions.outputPath;
        expect(
          actions.status,
          TarotBackupRestoreActionStatus.succeeded,
          reason: actions.failureCode,
        );
        expect(Directory(selectedPackage!).existsSync(), isTrue);

        expect(await actions.selectRestoreCandidate(), isTrue);
        await actions.restoreSelected();

        expect(actions.status, TarotBackupRestoreActionStatus.succeeded);
        expect(actions.message, '백업에서 복원했어요.');
        expect(Directory(actions.outputPath!).existsSync(), isTrue);
        expect(
          runtime.startupStatus,
          TarotRuntimeStartupStatus.readyEmpty,
          reason:
              '${runtime.failure?.technicalCode} / '
              '${runtime.startupRecoveryResult?.failureCode}',
        );
      } finally {
        actions.dispose();
        await runtime.close();
        if (root.existsSync()) await root.delete(recursive: true);
      }
    },
  );
}
