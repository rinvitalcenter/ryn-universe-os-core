import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/features/tarot/data/persistence/drift_tarot_reading_repository.dart';
import 'package:ryn_universe_os_core/features/tarot/data/persistence/tarot_reading_repository.dart';
import 'package:ryn_universe_os_core/features/tarot/domain/tarot_persistence_models.dart';

import 'synthetic_tarot_fixtures.dart';

void main() {
  group('DriftTarotReadingRepository', () {
    late RynAppDatabase database;
    late _MutableClock clock;
    late TarotReadingRepository repository;

    setUp(() {
      database = RynAppDatabase(NativeDatabase.memory());
      clock = _MutableClock(DateTime.utc(2026, 2, 1, 10));
      repository = DriftTarotReadingRepository(database, clock: clock.call);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'create completed reading is atomic and features it on Home',
      () async {
        final result = await repository.createCompletedReading(
          syntheticInput(placementCount: 3),
        );

        expect(result.isSuccess, isTrue);
        expect(await _count(database, 'tarot_readings'), 1);
        expect(await _count(database, 'tarot_card_placements'), 3);
        expect(await _count(database, 'tarot_interpretations'), 1);
        expect(
          (await repository.getActiveHomeReadingId()).value,
          'reading.synthetic.01',
        );
      },
    );

    test('same ID and same immutable payload is idempotent', () async {
      final input = syntheticInput(placementCount: 3);
      final first = await repository.createCompletedReading(input);
      final second = await repository.createCompletedReading(input);

      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);
      expect(await _count(database, 'tarot_readings'), 1);
      expect(await _count(database, 'tarot_card_placements'), 3);
    });

    test('same ID and different immutable payload returns conflict', () async {
      await repository.createCompletedReading(syntheticInput());

      final conflict = await repository.createCompletedReading(
        syntheticInput(question: 'SYNTHETIC_QUESTION_CONFLICT'),
      );

      expect(conflict.error?.code, RepositoryErrorCode.conflict);
      final stored = await repository.getReadingById('reading.synthetic.01');
      expect(stored.value!.snapshot.readingQuestionText, syntheticQuestionA);
    });

    test('placement insert failure rolls back parent and Home state', () async {
      await database.customStatement('''
CREATE TRIGGER synthetic_fail_second_placement
BEFORE INSERT ON tarot_card_placements
WHEN NEW.placement_order = 2
BEGIN
  SELECT RAISE(ABORT, 'SYNTHETIC_PLACEMENT_FAILURE');
END
''');

      final result = await repository.createCompletedReading(
        syntheticInput(placementCount: 3),
      );

      expect(result.isFailure, isTrue);
      expect(await _count(database, 'tarot_readings'), 0);
      expect(await _count(database, 'tarot_card_placements'), 0);
      expect((await repository.getActiveHomeReadingId()).value, isNull);
    });

    test(
      'save interpretation preserves snapshot facts and created timestamp',
      () async {
        await repository.createCompletedReading(syntheticInput());
        final before = await repository.getReadingById('reading.synthetic.01');
        final createdAt = await _interpretationCreatedAt(database);
        clock.now = DateTime.utc(2026, 2, 1, 11);

        final saved = await repository.saveInterpretation(
          TarotInterpretationUpdate(
            readingInstanceId: 'reading.synthetic.01',
            wholeImageObservation: 'SYNTHETIC_OBSERVATION_UPDATED',
          ),
        );

        expect(saved.isSuccess, isTrue);
        expect(
          saved.value!.snapshot.readingQuestionText,
          before.value!.snapshot.readingQuestionText,
        );
        expect(
          saved.value!.snapshot.placements.single.cardId,
          before.value!.snapshot.placements.single.cardId,
        );
        expect(await _interpretationCreatedAt(database), createdAt);
        expect(saved.value!.updatedAt, clock.now);
      },
    );

    test(
      'one-field interpretation update preserves the other fields',
      () async {
        await repository.createCompletedReading(syntheticInput());

        final saved = await repository.saveInterpretation(
          TarotInterpretationUpdate(
            readingInstanceId: 'reading.synthetic.01',
            smallAction: 'SYNTHETIC_ACTION_UPDATED',
          ),
        );

        expect(
          saved.value!.interpretation!.wholeImageObservation,
          syntheticObservationA,
        );
        expect(saved.value!.interpretation!.flowInterpretation, syntheticFlowA);
        expect(saved.value!.interpretation!.coreMessage, syntheticMessageA);
        expect(
          saved.value!.interpretation!.smallAction,
          'SYNTHETIC_ACTION_UPDATED',
        );
      },
    );

    test('display question update preserves immutable original', () async {
      await repository.createCompletedReading(syntheticInput());
      clock.now = DateTime.utc(2026, 2, 1, 11);

      final updated = await repository.updateDisplayQuestion(
        'reading.synthetic.01',
        syntheticQuestionDisplayA,
      );

      expect(updated.value!.snapshot.readingQuestionText, syntheticQuestionA);
      expect(updated.value!.questionDisplayText, syntheticQuestionDisplayA);
      expect(updated.value!.updatedAt, clock.now);
    });

    test('empty display question is rejected', () async {
      await repository.createCompletedReading(syntheticInput());

      final updated = await repository.updateDisplayQuestion(
        'reading.synthetic.01',
        '   ',
      );

      expect(updated.error?.code, RepositoryErrorCode.validationFailed);
    });

    test(
      'hide Home keeps record and does not change reading updated_at',
      () async {
        await repository.createCompletedReading(syntheticInput());
        final before = (await repository.getReadingById(
          'reading.synthetic.01',
        )).value!;
        clock.now = DateTime.utc(2026, 2, 1, 12);

        final hidden = await repository.hideActiveHomeReading();
        final after = (await repository.getReadingById(
          'reading.synthetic.01',
        )).value!;

        expect(hidden.isSuccess, isTrue);
        expect((await repository.getActiveHomeReadingId()).value, isNull);
        expect(after.updatedAt, before.updatedAt);
        expect(await _count(database, 'tarot_readings'), 1);
        expect(
          await _stateUpdatedAt(database),
          clock.now.microsecondsSinceEpoch,
        );
      },
    );

    test(
      'activate continuing reading changes only Home singleton state',
      () async {
        await repository.createCompletedReading(syntheticInput());
        await repository.hideActiveHomeReading();
        final before = (await repository.getReadingById(
          'reading.synthetic.01',
        )).value!;
        clock.now = DateTime.utc(2026, 2, 1, 13);

        final activated = await repository.activateHomeReading(
          'reading.synthetic.01',
        );
        final after = (await repository.getReadingById(
          'reading.synthetic.01',
        )).value!;

        expect(activated.isSuccess, isTrue);
        expect(
          (await repository.getActiveHomeReadingId()).value,
          'reading.synthetic.01',
        );
        expect(after.updatedAt, before.updatedAt);
      },
    );

    test('activating finished reading is rejected', () async {
      await repository.createCompletedReading(syntheticInput());
      await repository.finishReading('reading.synthetic.01');

      final activated = await repository.activateHomeReading(
        'reading.synthetic.01',
      );

      expect(activated.error?.code, RepositoryErrorCode.validationFailed);
      expect((await repository.getActiveHomeReadingId()).value, isNull);
    });

    test(
      'finish clears active Home state and retains Records aggregate',
      () async {
        await repository.createCompletedReading(syntheticInput());
        clock.now = DateTime.utc(2026, 2, 1, 14);

        final finished = await repository.finishReading('reading.synthetic.01');

        expect(finished.value!.lifecycle, TarotReadingLifecycle.finished);
        expect(finished.value!.finishedAt, clock.now);
        expect((await repository.getActiveHomeReadingId()).value, isNull);
        expect(
          (await repository.getReadingById('reading.synthetic.01')).isSuccess,
          isTrue,
        );
      },
    );

    test('reactivate-and-feature is atomic and clears finished_at', () async {
      await repository.createCompletedReading(syntheticInput());
      await repository.finishReading('reading.synthetic.01');
      clock.now = DateTime.utc(2026, 2, 1, 15);

      final reactivated = await repository.reactivateAndFeatureReading(
        'reading.synthetic.01',
      );

      expect(reactivated.value!.lifecycle, TarotReadingLifecycle.continuing);
      expect(reactivated.value!.finishedAt, isNull);
      expect(reactivated.value!.updatedAt, clock.now);
      expect(
        (await repository.getActiveHomeReadingId()).value,
        'reading.synthetic.01',
      );
    });

    test(
      'reactivate continuing record features it without changing reading updated_at',
      () async {
        await repository.createCompletedReading(syntheticInput());
        await repository.hideActiveHomeReading();
        final before = (await repository.getReadingById(
          'reading.synthetic.01',
        )).value!;
        clock.now = DateTime.utc(2026, 2, 1, 16);

        final reactivated = await repository.reactivateAndFeatureReading(
          'reading.synthetic.01',
        );

        expect(reactivated.value!.updatedAt, before.updatedAt);
        expect(
          (await repository.getActiveHomeReadingId()).value,
          'reading.synthetic.01',
        );
        expect(
          await _stateUpdatedAt(database),
          clock.now.microsecondsSinceEpoch,
        );
      },
    );

    test('active Home singleton permits at most one reading', () async {
      await repository.createCompletedReading(
        syntheticInput(readingId: 'reading.synthetic.01'),
      );
      await repository.createCompletedReading(
        syntheticInput(readingId: 'reading.synthetic.02'),
      );

      expect(
        (await repository.getActiveHomeReadingId()).value,
        'reading.synthetic.02',
      );
      expect(await _count(database, 'app_runtime_state'), 1);
    });

    test(
      'load all returns newest reading first with deterministic ID tie-breaker',
      () async {
        await repository.createCompletedReading(
          syntheticInput(readingId: 'reading.synthetic.b'),
        );
        await repository.createCompletedReading(
          syntheticInput(readingId: 'reading.synthetic.a'),
        );

        final loaded = await repository.loadAllReadings();

        expect(
          loaded.value!.map((record) => record.snapshot.readingInstanceId),
          <String>['reading.synthetic.a', 'reading.synthetic.b'],
        );
      },
    );

    test('manuallyRecorded source type round trips', () async {
      final created = await repository.createCompletedReading(
        syntheticInput(sourceType: TarotReadingOrigin.manuallyRecorded),
      );

      expect(created.value!.sourceType, TarotReadingOrigin.manuallyRecorded);
    });
  });
}

final class _MutableClock {
  _MutableClock(this.now);
  DateTime now;
  DateTime call() => now;
}

Future<int> _count(RynAppDatabase database, String table) async {
  final row = await database
      .customSelect('SELECT COUNT(*) AS total FROM $table')
      .getSingle();
  return row.read<int>('total');
}

Future<int> _interpretationCreatedAt(RynAppDatabase database) async {
  final row = await database
      .customSelect('SELECT created_at_utc_us FROM tarot_interpretations')
      .getSingle();
  return row.read<int>('created_at_utc_us');
}

Future<int> _stateUpdatedAt(RynAppDatabase database) async {
  final row = await database
      .customSelect(
        "SELECT updated_at_utc_us FROM app_runtime_state WHERE state_key = 'main'",
      )
      .getSingle();
  return row.read<int>('updated_at_utc_us');
}
