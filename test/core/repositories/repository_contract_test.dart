import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/repositories/app_settings_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/audit_trail_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_app_settings_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_audit_trail_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/fakes/fake_obsidian_report_ref_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/obsidian_report_ref_repository.dart';
import 'package:ryn_universe_os_core/core/repositories/redaction_state.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_context.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';

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
}
