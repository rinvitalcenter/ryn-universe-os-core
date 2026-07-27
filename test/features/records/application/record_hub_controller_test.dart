import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/records/application/record_hub_controller.dart';
import 'package:ryn_universe_os_core/features/records/application/record_summary_adapter.dart';
import 'package:ryn_universe_os_core/features/records/domain/record_summary.dart';

void main() {
  RecordSummary summary({
    required String id,
    required DateTime occurredAt,
    RecordModuleType module = RecordModuleType.tarot,
    RecordDisplayStatus status = RecordDisplayStatus.continuing,
    String? personId,
    String title = '기록 제목',
    List<String> searchTerms = const [],
  }) => RecordSummary(
    key: RecordKey(moduleType: module, canonicalRecordId: id),
    moduleType: module,
    recordType: RecordType.tarotSelfReading,
    occurredAt: occurredAt,
    updatedAt: occurredAt.add(const Duration(hours: 1)),
    title: title,
    shortSummary: 'RWS · 3카드 · 3장',
    personId: personId,
    status: status,
    capabilities: const RecordCapabilities(
      canPreview: true,
      canOpenFullDetail: true,
      canShowOnHome: true,
    ),
    searchTerms: searchTerms,
  );

  test('RecordKey identity combines module and canonical ID', () {
    const tarot = RecordKey(
      moduleType: RecordModuleType.tarot,
      canonicalRecordId: 'same-id',
    );
    const study = RecordKey(
      moduleType: RecordModuleType.study,
      canonicalRecordId: 'same-id',
    );

    expect(tarot, isNot(study));
    expect({tarot, study}, hasLength(2));
    expect(
      tarot,
      const RecordKey(
        moduleType: RecordModuleType.tarot,
        canonicalRecordId: 'same-id',
      ),
    );
  });

  test('controller sorts newest first and drops removed source selection', () {
    final controller = RecordHubController();
    final older = summary(id: 'older', occurredAt: DateTime(2026, 7, 1));
    final newer = summary(id: 'newer', occurredAt: DateTime(2026, 7, 3));

    controller.replaceSummaries([older, newer]);
    expect(controller.visibleSummaries.map((item) => item.key), [
      newer.key,
      older.key,
    ]);
    expect(controller.selectedKey, newer.key);

    controller.select(older.key);
    controller.replaceSummaries([newer]);
    expect(controller.selectedKey, newer.key);
    expect(controller.summaryFor(older.key), isNull);
  });

  test('filters compose with AND and normalize case', () {
    final controller = RecordHubController();
    final match = summary(
      id: 'match',
      occurredAt: DateTime(2026, 7, 12),
      personId: 'person-1',
      title: '내 선택의 기준',
      searchTerms: const ['Universal Waite', 'The Hermit'],
    );
    final wrongPerson = summary(
      id: 'wrong-person',
      occurredAt: DateTime(2026, 7, 12),
      personId: 'person-2',
      searchTerms: const ['universal waite'],
    );
    final wrongDate = summary(
      id: 'wrong-date',
      occurredAt: DateTime(2026, 6, 1),
      personId: 'person-1',
      searchTerms: const ['universal waite'],
    );
    final finished = summary(
      id: 'finished',
      occurredAt: DateTime(2026, 7, 12),
      personId: 'person-1',
      status: RecordDisplayStatus.finished,
      searchTerms: const ['universal waite'],
    );
    controller.replaceSummaries([match, wrongPerson, wrongDate, finished]);

    controller.updateSearchQuery('UNIVERSAL');
    controller.updateModuleFilter(RecordModuleType.tarot);
    controller.updatePersonFilter('person-1');
    controller.updateDateRange(
      DateTime(2026, 7, 1),
      DateTime(2026, 7, 31, 23, 59, 59),
    );
    controller.updateStatusFilter(RecordDisplayStatus.continuing);

    expect(controller.visibleSummaries, [match]);
    expect(controller.hasActiveFilters, isTrue);

    controller.clearFilters();
    expect(controller.visibleSummaries, hasLength(4));
    expect(controller.hasActiveFilters, isFalse);
  });

  test('overlapping refreshes keep the newest completed request', () async {
    final first = Completer<List<RecordSummary>>();
    final second = Completer<List<RecordSummary>>();
    final adapter = _QueuedAdapter([first.future, second.future]);
    final controller = RecordHubController(adapters: [adapter]);
    final stale = summary(id: 'stale', occurredAt: DateTime(2026, 7, 1));
    final current = summary(id: 'current', occurredAt: DateTime(2026, 7, 2));

    final firstRefresh = controller.refresh();
    final secondRefresh = controller.refresh();
    second.complete([current]);
    await secondRefresh;
    first.complete([stale]);
    await firstRefresh;

    expect(controller.allSummaries, [current]);
  });

  test('late adapter completion is ignored after dispose', () async {
    final pending = Completer<List<RecordSummary>>();
    final controller = RecordHubController(
      adapters: [
        _QueuedAdapter([pending.future]),
      ],
    );

    final refresh = controller.refresh();
    controller.dispose();
    pending.complete([summary(id: 'late', occurredAt: DateTime(2026, 7, 1))]);

    await expectLater(refresh, completes);
  });

  test('person filter only matches canonical non-null person IDs', () {
    final controller = RecordHubController();
    controller.replaceSummaries([
      summary(id: 'anonymous', occurredAt: DateTime(2026, 7, 1)),
      summary(
        id: 'linked',
        occurredAt: DateTime(2026, 7, 2),
        personId: 'person-1',
      ),
    ]);

    controller.updatePersonFilter('person-1');
    expect(controller.visibleSummaries.single.key.canonicalRecordId, 'linked');
    expect(controller.hasCanonicalPersonLinks, isTrue);
  });
}

final class _QueuedAdapter implements RecordSummaryAdapter {
  _QueuedAdapter(this.responses);

  final List<Future<List<RecordSummary>>> responses;
  var _index = 0;

  @override
  RecordModuleType get moduleType => RecordModuleType.tarot;

  @override
  Future<List<RecordSummary>> loadSummaries() => responses[_index++];
}
