import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/application/saju_daeun_seun_controller.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_snapshot_repository.dart';

void main() {
  final natalEngine = SajuCalculationEngine.production(
    utcNow: () => DateTime.utc(2026, 8, 1),
  );
  final derivedEngine = DaeunSeunCalculationEngine.production();

  SajuChartSnapshot snapshot({
    int year = 1990,
    int month = 3,
    int day = 15,
    SajuGender gender = SajuGender.male,
    bool hourUnknown = false,
  }) => natalEngine.calculate(
    SajuBirthInput.solar(
      date: SajuLocalDate(year, month, day),
      time: hourUnknown ? null : const SajuLocalTime(10, 30),
      gender: gender,
    ),
  );

  SajuPersistedSnapshot persisted(
    SajuChartSnapshot value, {
    String id = 'snapshot.r1',
    int revision = 1,
    String personId = 'person.1',
  }) => SajuPersistedSnapshot(
    id: id,
    personId: personId,
    sourceBirthProfileId: null,
    chartGroupId: 'chart.1',
    revisionNumber: revision,
    revisionReason: SajuRevisionReason.initial,
    createdAtUtcUs: 1,
    inputFingerprintSha256: 'a' * 64,
    calculationSignatureSha256: 'b' * 64,
    snapshot: value,
  );

  test('initial and no-source state stay empty without fake revision', () {
    final controller = SajuDaeunSeunController();
    addTearDown(controller.dispose);

    expect(controller.sourceType, isNull);
    expect(controller.sourceSnapshot, isNull);
    expect(controller.sourceProvenance, isNull);
    expect(controller.daeunPhase, SajuDerivedPhase.idle);
    expect(controller.seunPhase, SajuDerivedPhase.idle);
    expect(controller.selectedDaeunSequence, isNull);
    expect(controller.selectedSeunYear, isNull);
    expect(controller.currentTab, SajuWorkspaceTab.natal);
  });

  test('invalid provenance fails both calculations closed', () async {
    final controller = SajuDaeunSeunController();
    addTearDown(controller.dispose);

    await controller.loadUnsavedSource(
      personId: ' ',
      natalCalculationGeneration: 1,
      snapshot: snapshot(),
    );

    expect(controller.daeunPhase, SajuDerivedPhase.error);
    expect(controller.seunPhase, SajuDerivedPhase.error);
    expect(controller.daeunError, contains('계산 정보를 확인할 수 없습니다'));
    expect(controller.seunError, controller.daeunError);
  });

  test('unsaved source preserves provenance and generation identity', () async {
    final value = snapshot();
    var daeunCalls = 0;
    final controller = SajuDaeunSeunController(
      daeunExecutor: (source) {
        daeunCalls += 1;
        return derivedEngine.calculateDaeun(source);
      },
      seunExecutor: derivedEngine.seunForYear,
      now: () => DateTime.utc(2026, 8, 1, 1),
    );
    addTearDown(controller.dispose);

    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: value,
    );

    final provenance = controller.sourceProvenance!;
    expect(controller.sourceType, SajuDaeunSeunSourceType.unsavedNatalResult);
    expect(provenance.personId, 'person.1');
    expect(provenance.natalCalculationGeneration, 1);
    expect(provenance.snapshotId, isNull);
    expect(provenance.chartGroupId, isNull);
    expect(provenance.revisionNumber, isNull);
    expect(provenance.provenanceSignature, value.deterministicSignature);
    expect(controller.sourceDeduplicationKey, contains('unsavedNatalResult'));
    expect(controller.sourceDeduplicationKey, contains('|1|'));
    expect(controller.daeunResult?.cycles, hasLength(11));
    expect(controller.seunEntries, hasLength(10));
    expect(controller.selectedDaeunSequence, 1);
    expect(daeunCalls, 1);

    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: value,
    );
    expect(daeunCalls, 1, reason: 'same source rebuild must deduplicate');

    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 2,
      snapshot: value,
    );
    expect(
      daeunCalls,
      2,
      reason: 'new natal calculation is a new source event',
    );
    expect(controller.selectedDaeunSequence, 1);
  });

  test(
    'persisted source preserves exact revision, hash and identity',
    () async {
      final value = snapshot(gender: SajuGender.female);
      final saved = persisted(value, id: 'snapshot.r3', revision: 3);
      final controller = SajuDaeunSeunController();
      addTearDown(controller.dispose);

      await controller.loadPersistedSource(saved);

      final provenance = controller.sourceProvenance!;
      expect(
        controller.sourceType,
        SajuDaeunSeunSourceType.persistedNatalSnapshot,
      );
      expect(provenance.snapshotId, 'snapshot.r3');
      expect(provenance.chartGroupId, 'chart.1');
      expect(provenance.revisionNumber, 3);
      expect(provenance.natalCalculationGeneration, isNull);
      expect(provenance.provenanceSignature, 'b' * 64);
      expect(controller.sourceDeduplicationKey, contains('snapshot.r3'));
      expect(controller.sourceDeduplicationKey, contains('|3|'));
      expect(controller.daeunResult?.cycles, hasLength(11));
    },
  );

  test(
    'save promotion reuses same-payload derived result and selection',
    () async {
      final value = snapshot(hourUnknown: true);
      var daeunCalls = 0;
      final controller = SajuDaeunSeunController(
        daeunExecutor: (source) {
          daeunCalls += 1;
          return derivedEngine.calculateDaeun(source);
        },
        seunExecutor: derivedEngine.seunForYear,
      );
      addTearDown(controller.dispose);

      await controller.loadUnsavedSource(
        personId: 'person.1',
        natalCalculationGeneration: 8,
        snapshot: value,
      );
      await controller.selectDaeunCycle(2);
      final selectedYear = controller.seunEntries.first.gregorianYear;
      controller.selectSeunYear(selectedYear);
      final originalResult = controller.daeunResult;

      await controller.promoteToPersistedSource(
        persisted(value, id: 'snapshot.saved', revision: 1),
      );

      expect(
        controller.sourceType,
        SajuDaeunSeunSourceType.persistedNatalSnapshot,
      );
      expect(controller.sourceProvenance?.snapshotId, 'snapshot.saved');
      expect(controller.sourceProvenance?.revisionNumber, 1);
      expect(controller.daeunResult, same(originalResult));
      expect(controller.selectedDaeunSequence, 2);
      expect(controller.selectedSeunYear, selectedYear);
      expect(
        daeunCalls,
        1,
        reason: 'unknown-time 1440 evaluation must not repeat',
      );
    },
  );

  test(
    'promotion with different natal payload resets and recalculates',
    () async {
      final first = snapshot();
      final second = snapshot(year: 2023, month: 6, day: 15);
      var daeunCalls = 0;
      final controller = SajuDaeunSeunController(
        daeunExecutor: (source) {
          daeunCalls += 1;
          return derivedEngine.calculateDaeun(source);
        },
        seunExecutor: derivedEngine.seunForYear,
      );
      addTearDown(controller.dispose);

      await controller.loadUnsavedSource(
        personId: 'person.1',
        natalCalculationGeneration: 1,
        snapshot: first,
      );
      await controller.selectDaeunCycle(2);

      await controller.promoteToPersistedSource(persisted(second));

      expect(daeunCalls, 2);
      expect(controller.sourceSnapshot, same(second));
      expect(controller.selectedDaeunSequence, 1);
    },
  );

  test('promotion with a different Person resets and recalculates', () async {
    final value = snapshot();
    var daeunCalls = 0;
    final controller = SajuDaeunSeunController(
      daeunExecutor: (source) {
        daeunCalls += 1;
        return derivedEngine.calculateDaeun(source);
      },
      seunExecutor: derivedEngine.seunForYear,
    );
    addTearDown(controller.dispose);

    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: value,
    );
    await controller.selectDaeunCycle(2);

    await controller.promoteToPersistedSource(
      persisted(value, personId: 'person.2'),
    );

    expect(controller.sourceProvenance?.personId, 'person.2');
    expect(controller.selectedDaeunSequence, 1);
    expect(daeunCalls, 2);
  });

  test('same-source promotion preserves an in-flight calculation', () async {
    final value = snapshot();
    final daeunGate = Completer<DaeunCalculationResult>();
    var daeunCalls = 0;
    final controller = SajuDaeunSeunController(
      daeunExecutor: (source) {
        daeunCalls += 1;
        return daeunGate.future;
      },
      seunExecutor: derivedEngine.seunForYear,
    );
    addTearDown(controller.dispose);

    final loading = controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: value,
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.daeunPhase, SajuDerivedPhase.calculating);

    await controller.promoteToPersistedSource(persisted(value));
    daeunGate.complete(derivedEngine.calculateDaeun(value));
    await loading;

    expect(
      controller.sourceType,
      SajuDaeunSeunSourceType.persistedNatalSnapshot,
    );
    expect(controller.daeunPhase, SajuDerivedPhase.ready);
    expect(controller.daeunResult?.cycles, hasLength(11));
    expect(controller.seunPhase, SajuDerivedPhase.ready);
    expect(controller.seunEntries, hasLength(10));
    expect(daeunCalls, 1);
  });

  test('Daeun failure does not block independent annual Seun labels', () async {
    for (final code in <DaeunSeunErrorCode>[
      DaeunSeunErrorCode.unknownTimeAmbiguous,
      DaeunSeunErrorCode.genderRequired,
      DaeunSeunErrorCode.unsupportedForecastHorizon,
    ]) {
      final value = snapshot();
      final controller = SajuDaeunSeunController(
        daeunExecutor: (_) => throw DaeunSeunCalculationException(
          code: code,
          userMessage: 'raw domain detail',
          detail: 'secret',
        ),
        seunExecutor: derivedEngine.seunForYear,
      );

      await controller.loadUnsavedSource(
        personId: 'person.1',
        natalCalculationGeneration: code.index + 1,
        snapshot: value,
      );

      expect(controller.daeunPhase, SajuDerivedPhase.error);
      expect(controller.daeunError, isNot(contains('raw domain detail')));
      expect(controller.daeunError, isNot(contains(code.name)));
      expect(controller.seunPhase, SajuDerivedPhase.ready);
      expect(controller.seunEntries, hasLength(10));
      expect(
        controller.seunEntries.first.gregorianYear,
        value.convertedSolarDate.year,
      );
      controller.dispose();
    }
  });

  test('Seun failure leaves a valid Daeun result intact', () async {
    final controller = SajuDaeunSeunController();
    addTearDown(controller.dispose);
    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: snapshot(),
    );
    final result = controller.daeunResult;

    await controller.generateSeunYears(startYear: 2151);

    expect(controller.daeunPhase, SajuDerivedPhase.ready);
    expect(controller.daeunResult, same(result));
    expect(controller.seunPhase, SajuDerivedPhase.error);
    expect(controller.seunError, '세운 연도는 1990년부터 2159년까지 지원합니다.');
  });

  test(
    'cycle selection creates exact ten years without changing pillars',
    () async {
      final value = snapshot();
      final controller = SajuDaeunSeunController();
      addTearDown(controller.dispose);
      await controller.loadUnsavedSource(
        personId: 'person.1',
        natalCalculationGeneration: 1,
        snapshot: value,
      );

      final baseline = derivedEngine
          .seunForYear(value, 2006)
          .pillar
          .canonicalId;
      await controller.selectDaeunCycle(2);

      expect(controller.selectedDaeunSequence, 2);
      expect(controller.seunEntries, hasLength(10));
      expect(controller.seunEntries.first.gregorianYear, 2006);
      expect(controller.seunEntries.last.gregorianYear, 2015);
      expect(controller.seunEntries.first.pillar.canonicalId, baseline);
      controller.selectSeunYear(2010);
      expect(controller.selectedSeunYear, 2010);
      controller.selectTab(SajuWorkspaceTab.seun);
      expect(controller.currentTab, SajuWorkspaceTab.seun);
    },
  );

  test('ready Daeun is not recalculated for the same source', () async {
    var daeunCalls = 0;
    final controller = SajuDaeunSeunController(
      daeunExecutor: (value) {
        daeunCalls += 1;
        return derivedEngine.calculateDaeun(value);
      },
      seunExecutor: derivedEngine.seunForYear,
    );
    addTearDown(controller.dispose);
    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: snapshot(),
    );

    await controller.calculateDaeun();

    expect(daeunCalls, 1);
  });

  test('latest overlapping Seun range wins', () async {
    final controller = SajuDaeunSeunController(
      daeunExecutor: derivedEngine.calculateDaeun,
      seunExecutor: (value, year, {selectedDaeun}) async {
        if (year < 2006) {
          await Future<void>.delayed(const Duration(milliseconds: 3));
        }
        return derivedEngine.seunForYear(
          value,
          year,
          selectedDaeun: selectedDaeun,
        );
      },
    );
    addTearDown(controller.dispose);
    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: snapshot(),
    );

    final stale = controller.generateSeunYears(startYear: 1996);
    final latest = controller.generateSeunYears(startYear: 2006);
    await Future.wait([stale, latest]);

    expect(controller.seunPhase, SajuDerivedPhase.ready);
    expect(controller.seunEntries.first.gregorianYear, 2006);
    expect(controller.seunEntries.last.gregorianYear, 2015);
  });

  test('invalid Seun range cancels an older valid request', () async {
    final gate = Completer<void>();
    var delay1996 = false;
    final controller = SajuDaeunSeunController(
      daeunExecutor: derivedEngine.calculateDaeun,
      seunExecutor: (value, year, {selectedDaeun}) async {
        if (delay1996 && year == 1996) await gate.future;
        return derivedEngine.seunForYear(
          value,
          year,
          selectedDaeun: selectedDaeun,
        );
      },
    );
    addTearDown(controller.dispose);
    await controller.loadUnsavedSource(
      personId: 'person.1',
      natalCalculationGeneration: 1,
      snapshot: snapshot(),
    );

    delay1996 = true;
    final stale = controller.generateSeunYears(startYear: 1996);
    await Future<void>.delayed(Duration.zero);
    await controller.generateSeunYears(startYear: 2151);
    gate.complete();
    await stale;

    expect(controller.seunPhase, SajuDerivedPhase.error);
    expect(controller.seunEntries, isEmpty);
    expect(controller.seunError, '세운 연도는 1990년부터 2159년까지 지원합니다.');
  });

  test(
    'clear source resets derived state but keeps selected workspace tab',
    () async {
      final controller = SajuDaeunSeunController();
      addTearDown(controller.dispose);
      controller.selectTab(SajuWorkspaceTab.daeun);
      await controller.loadUnsavedSource(
        personId: 'person.1',
        natalCalculationGeneration: 1,
        snapshot: snapshot(),
      );

      controller.clearSource();

      expect(controller.currentTab, SajuWorkspaceTab.daeun);
      expect(controller.sourceSnapshot, isNull);
      expect(controller.daeunPhase, SajuDerivedPhase.idle);
      expect(controller.seunPhase, SajuDerivedPhase.idle);
      expect(controller.selectedDaeunSequence, isNull);
      expect(controller.selectedSeunYear, isNull);
    },
  );
}
