import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/runtime_data_profile.dart';
import 'package:ryn_universe_os_core/features/tarot/application/tarot_runtime_controller.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';
import 'package:sqlite3/sqlite3.dart';

import '../persistence/synthetic_tarot_fixtures.dart';

void main() {
  group('Tarot development runtime bootstrap', () {
    late Directory temporaryRoot;
    late RynRuntimeDataPathContract paths;

    setUp(() async {
      temporaryRoot = await Directory.systemTemp.createTemp(
        'ryn-synthetic-runtime-',
      );
      paths = RynRuntimeDataPathContract.forApplicationSupportRoot(
        temporaryRoot,
      );
    });

    tearDown(() async {
      if (temporaryRoot.existsSync()) {
        await temporaryRoot.delete(recursive: true);
      }
    });

    test(
      'first run creates one shared version-six development database',
      () async {
        final controller = TarotRuntimeController.development(
          pathContract: paths,
        );
        final development = paths.resolve(RynDataProfile.development);
        final production = paths.resolve(RynDataProfile.productionReserved);

        await controller.bootstrap();

        expect(controller.startupStatus, TarotRuntimeStartupStatus.readyEmpty);
        expect(controller.databasePath, development.databasePath);
        expect(File(development.databasePath).existsSync(), isTrue);
        expect(File(production.databasePath).existsSync(), isFalse);
        expect(
          Directory(production.runtimeDirectoryPath).existsSync(),
          isFalse,
        );
        final check = sqlite3.open(
          development.databasePath,
          mode: OpenMode.readOnly,
        );
        expect(check.userVersion, 6);
        check.close();
        await controller.close();
      },
    );

    test('QA mode opens, closes, and reopens only its isolated path', () async {
      final standard = paths.resolveMode(
        RynRuntimeDataMode.standardDevelopment,
      );
      final qa = paths.resolveMode(RynRuntimeDataMode.tarotPersistenceQa);
      final first = TarotRuntimeController.development(
        pathContract: paths,
        runtimeDataMode: RynRuntimeDataMode.tarotPersistenceQa,
      );

      await first.bootstrap();

      expect(first.startupStatus, TarotRuntimeStartupStatus.readyEmpty);
      expect(first.databasePath, qa.databasePath);
      expect(File(qa.databasePath).existsSync(), isTrue);
      expect(File(standard.databasePath).existsSync(), isFalse);
      await first.close();

      final second = TarotRuntimeController.development(
        pathContract: paths,
        runtimeDataMode: RynRuntimeDataMode.tarotPersistenceQa,
      );
      await second.bootstrap();

      expect(second.startupStatus, TarotRuntimeStartupStatus.readyEmpty);
      expect(second.databasePath, qa.databasePath);
      await second.close();
    });

    test('valid empty database is distinct from load failure', () async {
      final controller = TarotRuntimeController.development(
        pathContract: paths,
      );
      expect(controller.startupStatus, TarotRuntimeStartupStatus.initializing);

      await controller.bootstrap();

      expect(controller.startupStatus, TarotRuntimeStartupStatus.readyEmpty);
      expect(controller.failure, isNull);
      await controller.close();
    });

    test(
      'corrupt database enters recoveryRequired without replacement',
      () async {
        final development = paths.resolve(RynDataProfile.development);
        await Directory(
          development.runtimeDirectoryPath,
        ).create(recursive: true);
        final corruptBytes = <int>[0x52, 0x59, 0x4E, 0x2D, 0x42, 0x41, 0x44];
        await File(development.databasePath).writeAsBytes(corruptBytes);
        final before = await File(development.databasePath).readAsBytes();
        final controller = TarotRuntimeController.development(
          pathContract: paths,
        );

        await controller.bootstrap();

        expect(
          controller.startupStatus,
          TarotRuntimeStartupStatus.recoveryRequired,
        );
        expect(
          controller.failure?.category,
          TarotRuntimeFailureCategory.loadFailed,
        );
        expect(await File(development.databasePath).readAsBytes(), before);
        await controller.close();
      },
    );

    test('newer schema enters unsupportedNewerSchema', () async {
      final development = paths.resolve(RynDataProfile.development);
      await Directory(development.runtimeDirectoryPath).create(recursive: true);
      final database = sqlite3.open(development.databasePath);
      database.execute('PRAGMA user_version = 99');
      database.close();
      final controller = TarotRuntimeController.development(
        pathContract: paths,
      );

      await controller.bootstrap();

      expect(
        controller.startupStatus,
        TarotRuntimeStartupStatus.unsupportedNewerSchema,
      );
      expect(
        controller.failure?.category,
        TarotRuntimeFailureCategory.unsupportedSchema,
      );
      await controller.close();
    });
  });

  group('durable self Tarot value loop', () {
    late Directory temporaryRoot;
    late RynRuntimeDataPathContract paths;

    setUp(() async {
      temporaryRoot = await Directory.systemTemp.createTemp(
        'ryn-synthetic-restart-',
      );
      paths = RynRuntimeDataPathContract.forApplicationSupportRoot(
        temporaryRoot,
      );
    });

    tearDown(() async {
      if (temporaryRoot.existsSync()) {
        await temporaryRoot.delete(recursive: true);
      }
    });

    test(
      'save close restart hydrates snapshot draft and active Home ID',
      () async {
        final input = syntheticInput(placementCount: 3);
        final instanceA = TarotRuntimeController.development(
          pathContract: paths,
        );
        await instanceA.bootstrap();

        final saved = await instanceA.completeSelfReading(
          snapshot: input.snapshot,
          readingTimezoneOffsetMinutes: input.readingTimezoneOffsetMinutes,
          interpretation: input.interpretation,
        );
        expect(saved, isTrue);
        expect(
          instanceA.activeReadingInstanceId,
          input.snapshot.readingInstanceId,
        );
        await instanceA.close();

        final instanceB = TarotRuntimeController.development(
          pathContract: paths,
        );
        await instanceB.bootstrap();

        expect(
          instanceB.startupStatus,
          TarotRuntimeStartupStatus.readyWithData,
        );
        expect(
          instanceB.snapshots.single.readingInstanceId,
          input.snapshot.readingInstanceId,
        );
        expect(instanceB.snapshots.single.placements.length, 3);
        expect(
          instanceB.activeReadingInstanceId,
          input.snapshot.readingInstanceId,
        );
        expect(
          instanceB
              .draftFor(input.snapshot.readingInstanceId)
              ?.wholeImageObservation,
          syntheticObservationA,
        );
        expect(
          instanceB
              .recordFor(input.snapshot.readingInstanceId)
              ?.readingTimezoneOffsetMinutes,
          540,
        );
        await instanceB.close();
      },
    );

    test(
      'explicit four-field save survives restart with line breaks',
      () async {
        final input = syntheticInput(includeInterpretation: false);
        final controller = TarotRuntimeController.development(
          pathContract: paths,
        );
        await controller.bootstrap();
        await controller.completeSelfReading(
          snapshot: input.snapshot,
          readingTimezoneOffsetMinutes: input.readingTimezoneOffsetMinutes,
        );
        final draft = TarotInterpretationSessionDraft(
          readingInstanceId: input.snapshot.readingInstanceId,
          wholeImageObservation: 'SYNTHETIC_OBSERVATION_A\nLINE_2',
          flowInterpretation: syntheticFlowA,
          coreMessage: syntheticMessageA,
          smallAction: syntheticActionA,
        );
        controller.retainDraft(draft);
        expect(
          controller.saveStatusFor(input.snapshot.readingInstanceId),
          TarotDraftSaveStatus.dirty,
        );

        expect(
          await controller.saveInterpretation(input.snapshot.readingInstanceId),
          isTrue,
        );
        expect(
          controller.saveStatusFor(input.snapshot.readingInstanceId),
          TarotDraftSaveStatus.saved,
        );
        await controller.close();

        final restarted = TarotRuntimeController.development(
          pathContract: paths,
        );
        await restarted.bootstrap();
        expect(
          restarted
              .draftFor(input.snapshot.readingInstanceId)
              ?.wholeImageObservation,
          'SYNTHETIC_OBSERVATION_A\nLINE_2',
        );
        await restarted.close();
      },
    );

    test('hide and reactivate persist without duplicating a record', () async {
      final input = syntheticInput();
      final controller = TarotRuntimeController.development(
        pathContract: paths,
      );
      await controller.bootstrap();
      await controller.completeSelfReading(
        snapshot: input.snapshot,
        readingTimezoneOffsetMinutes: input.readingTimezoneOffsetMinutes,
        interpretation: input.interpretation,
      );
      final updatedBefore = controller
          .recordFor(input.snapshot.readingInstanceId)!
          .updatedAt;

      expect(await controller.hideActiveFromHome(), isTrue);
      expect(controller.activeReadingInstanceId, isNull);
      expect(
        controller.recordFor(input.snapshot.readingInstanceId)!.updatedAt,
        updatedBefore,
      );
      expect(
        await controller.featureReading(input.snapshot.readingInstanceId),
        isTrue,
      );
      expect(controller.snapshots, hasLength(1));
      await controller.close();

      final restarted = TarotRuntimeController.development(pathContract: paths);
      await restarted.bootstrap();
      expect(
        restarted.activeReadingInstanceId,
        input.snapshot.readingInstanceId,
      );
      expect(restarted.snapshots, hasLength(1));
      await restarted.close();
    });

    test('same ID same immutable payload remains idempotent', () async {
      final input = syntheticInput();
      final controller = TarotRuntimeController.development(
        pathContract: paths,
      );
      await controller.bootstrap();

      expect(
        await controller.completeSelfReading(
          snapshot: input.snapshot,
          readingTimezoneOffsetMinutes: input.readingTimezoneOffsetMinutes,
          interpretation: input.interpretation,
        ),
        isTrue,
      );
      expect(
        await controller.completeSelfReading(
          snapshot: input.snapshot,
          readingTimezoneOffsetMinutes: input.readingTimezoneOffsetMinutes,
          interpretation: input.interpretation,
        ),
        isTrue,
      );
      expect(controller.snapshots, hasLength(1));
      await controller.close();
    });

    test('same ID different immutable payload reports conflict', () async {
      final original = syntheticInput();
      final changed = syntheticInput(question: 'SYNTHETIC_QUESTION_B');
      final controller = TarotRuntimeController.development(
        pathContract: paths,
      );
      await controller.bootstrap();
      await controller.completeSelfReading(
        snapshot: original.snapshot,
        readingTimezoneOffsetMinutes: original.readingTimezoneOffsetMinutes,
      );

      expect(
        await controller.completeSelfReading(
          snapshot: changed.snapshot,
          readingTimezoneOffsetMinutes: changed.readingTimezoneOffsetMinutes,
        ),
        isFalse,
      );
      expect(
        controller.failure?.category,
        TarotRuntimeFailureCategory.conflict,
      );
      expect(
        controller.snapshots.single.readingQuestionText,
        syntheticQuestionA,
      );
      await controller.close();
    });
  });
}
