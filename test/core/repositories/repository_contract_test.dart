import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/repositories/app_settings_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/audit_trail_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_app_settings_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_audit_trail_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_mission_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_obsidian_report_ref_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_task_card_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/mission_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/obsidian_report_ref_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/redaction_state.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_context.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/core/repositories/task_card_repository.dart';

void main() {
  final syntheticNow = DateTime.utc(2026, 1, 1, 12);
  final syntheticContext = RepositoryContext(
    actor: const SafeActorRef(actorType: 'synthetic_agent', actorId: 'fake-1'),
    occurredAt: syntheticNow,
    reason: 'synthetic contract test',
    correlationId: 'corr-synthetic-001',
  );

  group('AppSettingsRepository fake contract', () {
    test('stores and reads non-secret synthetic settings only', () async {
      final repository = FakeAppSettingsRepository();
      addTearDown(repository.close);

      final writeResult = await repository.setNonSecretSetting(
        key: 'ui.compact_mode',
        value: 'enabled',
        valueType: 'string',
        redactionState: RedactionState.noneRequired,
        context: syntheticContext,
      );
      expect(writeResult.isSuccess, isTrue);

      final readResult = await repository.readSetting('ui.compact_mode');
      expect(readResult.isSuccess, isTrue);
      expect(readResult.value, isA<AppSettingValue>());
      expect(readResult.value?.value, 'enabled');
      expect(readResult.value?.updatedAt, syntheticNow);
    });

    test('blocks secret-looking synthetic settings', () async {
      final repository = FakeAppSettingsRepository();
      addTearDown(repository.close);

      final result = await repository.setNonSecretSetting(
        key: 'provider.api_key',
        value: 'synthetic-placeholder',
        valueType: 'string',
        redactionState: RedactionState.secretAliasOnly,
        context: syntheticContext,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, RepositoryErrorCode.sensitiveDataBlocked);
      final readResult = await repository.readSetting('provider.api_key');
      expect(readResult.value, isNull);
    });
  });

  group('ObsidianReportRefRepository fake contract', () {
    test('stores report reference metadata without Markdown body content', () async {
      final repository = FakeObsidianReportRefRepository();
      addTearDown(repository.close);

      final linkResult = await repository.linkReportRef(
        id: 'report-synthetic-001',
        docType: 'qa_report',
        vaultPath: 'RynOS/reports/synthetic-report.md',
        sha256: '0' * 64,
        redactionState: RedactionState.redacted,
        context: syntheticContext,
      );
      expect(linkResult.isSuccess, isTrue);
      final linkedRef = linkResult.value!;
      expect(linkedRef, isA<ObsidianReportRefValue>());
      expect(linkedRef.vaultPath, endsWith('synthetic-report.md'));

      final readResult = await repository.readReportRef('report-synthetic-001');
      expect(readResult.isSuccess, isTrue);
      expect(readResult.value?.docType, 'qa_report');
      expect(readResult.value?.sha256, '0' * 64);
    });

    test('rejects empty report reference paths', () async {
      final repository = FakeObsidianReportRefRepository();
      addTearDown(repository.close);

      final result = await repository.linkReportRef(
        id: 'report-synthetic-empty-path',
        docType: 'qa_report',
        vaultPath: '   ',
        sha256: null,
        redactionState: RedactionState.needsReview,
        context: syntheticContext,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, RepositoryErrorCode.validationFailed);
    });
  });

  group('AuditTrailRepository fake contract', () {
    test('appends and lists synthetic redacted audit events', () async {
      final repository = FakeAuditTrailRepository();
      addTearDown(repository.close);

      final event = AuditTrailEntry(
        id: 'audit-synthetic-001',
        occurredAt: syntheticNow,
        actorType: 'synthetic_agent',
        actorId: 'fake-1',
        action: 'append_synthetic_contract_event',
        targetType: 'repository_contract',
        targetId: 'contract-1',
        beforeHash: null,
        afterHash: '1' * 64,
        redactedSnapshot: '{"synthetic":true,"redacted":true}',
        redactionState: RedactionState.redacted,
        reason: 'synthetic contract test',
        correlationId: 'corr-synthetic-001',
        createdAt: syntheticNow,
      );

      final appendResult = await repository.appendAuditEvent(
        event: event,
        context: syntheticContext,
      );
      expect(appendResult.isSuccess, isTrue);

      final listResult = await repository.listRecentAudit();
      expect(listResult.isSuccess, isTrue);
      final listedEvents = listResult.value!;
      expect(listedEvents, hasLength(1));
      expect(listedEvents.single.id, 'audit-synthetic-001');
    });

    test('preserves append-only semantics by rejecting duplicate event ids', () async {
      final repository = FakeAuditTrailRepository();
      addTearDown(repository.close);

      final event = AuditTrailEntry(
        id: 'audit-synthetic-duplicate',
        occurredAt: syntheticNow,
        actorType: 'synthetic_agent',
        action: 'append_synthetic_contract_event',
        targetType: 'repository_contract',
        redactionState: RedactionState.redacted,
        createdAt: syntheticNow,
      );

      final first = await repository.appendAuditEvent(
        event: event,
        context: syntheticContext,
      );
      final second = await repository.appendAuditEvent(
        event: event,
        context: syntheticContext,
      );

      expect(first.isSuccess, isTrue);
      expect(second.isFailure, isTrue);
      expect(second.error?.code, RepositoryErrorCode.conflict);
    });
  });


  group('MissionRepository fake contract', () {
    test('saves, reads, and lists active synthetic mission metadata', () async {
      final repository = FakeMissionRepository();
      addTearDown(repository.close);

      final mission = MissionValue(
        id: 'mission-synthetic-001',
        title: 'Synthetic repository contract mission',
        description: 'Synthetic mission metadata for fake contract coverage.',
        status: 'active',
        mode: 'manual',
        createdAt: syntheticNow,
      );

      final saveResult = await repository.saveMission(
        mission: mission,
        context: syntheticContext,
      );
      expect(saveResult.isSuccess, isTrue);
      expect(saveResult.value?.updatedAt, syntheticNow);

      final readResult = await repository.readMission('mission-synthetic-001');
      expect(readResult.isSuccess, isTrue);
      expect(readResult.value?.title, 'Synthetic repository contract mission');

      final listResult = await repository.listActiveMissions();
      expect(listResult.isSuccess, isTrue);
      expect(listResult.value, hasLength(1));
      expect(listResult.value?.single.id, 'mission-synthetic-001');
    });

    test('archives synthetic missions and excludes them from active list', () async {
      final repository = FakeMissionRepository();
      addTearDown(repository.close);

      final saveResult = await repository.saveMission(
        mission: MissionValue(
          id: 'mission-synthetic-archive',
          title: 'Synthetic archive mission',
          status: 'active',
          mode: 'manual',
          createdAt: syntheticNow,
        ),
        context: syntheticContext,
      );
      expect(saveResult.isSuccess, isTrue);

      final archiveAt = syntheticNow.add(const Duration(hours: 1));
      final archiveResult = await repository.archiveMission(
        id: 'mission-synthetic-archive',
        archivedAt: archiveAt,
        context: syntheticContext,
      );
      expect(archiveResult.isSuccess, isTrue);
      expect(archiveResult.value?.status, 'archived');
      expect(archiveResult.value?.archivedAt, archiveAt);

      final listResult = await repository.listActiveMissions();
      expect(listResult.isSuccess, isTrue);
      expect(listResult.value, isEmpty);
    });
  });

  group('TaskCardRepository fake contract', () {
    test('saves, reads, and lists synthetic cards by mission and lane', () async {
      final repository = FakeTaskCardRepository();
      addTearDown(repository.close);

      final card = TaskCardValue(
        id: 'task-synthetic-001',
        missionId: 'mission-synthetic-001',
        title: 'Synthetic repository contract card',
        description: 'Synthetic task card metadata for fake contract coverage.',
        lane: 'todo',
        status: 'ready',
        priority: 'medium',
        orderKey: '001',
        riskLevel: 'low',
        createdAt: syntheticNow,
      );

      final saveResult = await repository.saveTaskCard(
        card: card,
        context: syntheticContext,
      );
      expect(saveResult.isSuccess, isTrue);
      expect(saveResult.value?.updatedAt, syntheticNow);

      final readResult = await repository.readTaskCard('task-synthetic-001');
      expect(readResult.isSuccess, isTrue);
      expect(readResult.value?.missionId, 'mission-synthetic-001');

      final missionListResult = await repository.listTaskCardsForMission(
        missionId: 'mission-synthetic-001',
      );
      expect(missionListResult.isSuccess, isTrue);
      expect(missionListResult.value, hasLength(1));

      final laneListResult = await repository.listTaskCardsByLane(lane: 'todo');
      expect(laneListResult.isSuccess, isTrue);
      expect(laneListResult.value?.single.id, 'task-synthetic-001');
    });

    test('moves and archives synthetic task cards in memory', () async {
      final repository = FakeTaskCardRepository();
      addTearDown(repository.close);

      final saveResult = await repository.saveTaskCard(
        card: TaskCardValue(
          id: 'task-synthetic-transition',
          missionId: 'mission-synthetic-001',
          title: 'Synthetic transition card',
          lane: 'todo',
          status: 'ready',
          priority: 'high',
          riskLevel: 'medium',
          createdAt: syntheticNow,
        ),
        context: syntheticContext,
      );
      expect(saveResult.isSuccess, isTrue);

      final moveResult = await repository.moveTaskCard(
        id: 'task-synthetic-transition',
        lane: 'doing',
        orderKey: 'doing-001',
        context: syntheticContext,
      );
      expect(moveResult.isSuccess, isTrue);
      expect(moveResult.value?.lane, 'doing');
      expect(moveResult.value?.orderKey, 'doing-001');

      final todoListResult = await repository.listTaskCardsByLane(lane: 'todo');
      expect(todoListResult.isSuccess, isTrue);
      expect(todoListResult.value, isEmpty);

      final doingListResult = await repository.listTaskCardsByLane(lane: 'doing');
      expect(doingListResult.isSuccess, isTrue);
      expect(doingListResult.value?.single.id, 'task-synthetic-transition');

      final archiveAt = syntheticNow.add(const Duration(hours: 2));
      final archiveResult = await repository.archiveTaskCard(
        id: 'task-synthetic-transition',
        archivedAt: archiveAt,
        context: syntheticContext,
      );
      expect(archiveResult.isSuccess, isTrue);
      expect(archiveResult.value?.status, 'archived');
      expect(archiveResult.value?.archivedAt, archiveAt);

      final activeForMissionResult = await repository.listTaskCardsForMission(
        missionId: 'mission-synthetic-001',
      );
      expect(activeForMissionResult.isSuccess, isTrue);
      expect(activeForMissionResult.value, isEmpty);
    });
  });
}
