import 'package:flutter/material.dart';

import '../../../core/formatters/korean_date_time_formatter.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';
import 'records_tarot_spread_preview.dart';

class RecordsSessionPage extends StatelessWidget {
  const RecordsSessionPage({
    required this.results,
    required this.activeReadingInstanceId,
    required this.onOpenDetail,
    required this.onShowOnHome,
    required this.onStartSelfTarot,
    super.key,
  });

  final List<TarotReadingResultSnapshot> results;
  final String? activeReadingInstanceId;
  final ValueChanged<TarotReadingResultSnapshot> onOpenDetail;
  final ValueChanged<TarotReadingResultSnapshot> onShowOnHome;
  final VoidCallback onStartSelfTarot;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('records-session-page'),
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '나의 성장 기록',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '이번 실행에서 완료한 리딩을 살펴봅니다.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            _SessionNote(),
            const SizedBox(height: 24),
            if (results.isEmpty)
              _EmptyRecords(onStartSelfTarot: onStartSelfTarot)
            else
              for (var index = 0; index < results.length; index++) ...[
                _ResultRow(
                  snapshot: results[index],
                  isActive:
                      results[index].readingInstanceId ==
                      activeReadingInstanceId,
                  onOpenDetail: () => onOpenDetail(results[index]),
                  onShowOnHome: () => onShowOnHome(results[index]),
                ),
                if (index != results.length - 1) const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }
}

class _SessionNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            '앱을 닫으면 이 목록은 비워집니다.',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords({required this.onStartSelfTarot});

  final VoidCallback onStartSelfTarot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 42, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            '아직 완료한 리딩이 없습니다',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '셀프 타로를 마치면 이곳에서 결과를 다시 살펴볼 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onStartSelfTarot,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('새 셀프 타로 시작'),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.snapshot,
    required this.isActive,
    required this.onOpenDetail,
    required this.onShowOnHome,
  });

  final TarotReadingResultSnapshot snapshot;
  final bool isActive;
  final VoidCallback onOpenDetail;
  final VoidCallback onShowOnHome;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: Key('records-result-${snapshot.readingInstanceId}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final narrative = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    KoreanDateTimeFormatter.full(snapshot.readingAt),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 10),
                    Chip(
                      avatar: const Icon(Icons.home_rounded, size: 15),
                      label: const Text('현재 홈에 표시 중'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.readingQuestionText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${snapshot.deckNameSnapshot} · ${snapshot.spreadNameSnapshot} · ${snapshot.placements.length}장',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: onOpenDetail,
                    child: const Text('상세 보기'),
                  ),
                  if (!isActive)
                    TextButton.icon(
                      onPressed: onShowOnHome,
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: const Text('홈에 표시'),
                    ),
                ],
              ),
            ],
          );
          final preview = SizedBox(
            width: compact ? double.infinity : 260,
            child: RecordsTarotSpreadPreview(snapshot: snapshot),
          );
          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [narrative, const SizedBox(height: 18), preview],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: narrative),
                    const SizedBox(width: 24),
                    preview,
                  ],
                );
        },
      ),
    );
  }
}
