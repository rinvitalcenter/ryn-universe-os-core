import 'package:flutter/material.dart';

import '../../../core/text/user_text.dart';
import '../../oracle/domain/oracle_reading_result_snapshot.dart';

class ReadingAtelierPage extends StatelessWidget {
  const ReadingAtelierPage({
    super.key,
    required this.onStartTarot,
    required this.onStartOracle,
    this.recentOracleResult,
    this.onResumeOracle,
  });

  final VoidCallback onStartTarot;
  final VoidCallback onStartOracle;
  final OracleReadingResultSnapshot? recentOracleResult;
  final VoidCallback? onResumeOracle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final tarot = _AtelierDoorway(
          key: const Key('atelier-tarot-doorway'),
          eyebrow: 'TAROT',
          title: UserText.readingAtelierTarotTitle,
          body: '질문과 자리의 구조를 따라 흐름을 펼쳐봅니다.',
          actionLabel: UserText.readingAtelierStartTarot,
          actionKey: const Key('atelier-tarot-action'),
          icon: Icons.style_rounded,
          alignment: CrossAxisAlignment.start,
          onPressed: onStartTarot,
        );
        final oracle = _AtelierDoorway(
          key: const Key('atelier-oracle-doorway'),
          eyebrow: 'ORACLE',
          title: UserText.readingAtelierOracleTitle,
          body: '지금 필요한 메시지를 한 장 또는 세 장으로 만나봅니다.',
          actionLabel: UserText.readingAtelierStartOracle,
          actionKey: const Key('atelier-oracle-action'),
          icon: Icons.blur_on_rounded,
          alignment: CrossAxisAlignment.end,
          oracleIdentity: true,
          onPressed: onStartOracle,
        );
        final scene = _AtelierScene(
          result: recentOracleResult,
          onResume: onResumeOracle,
        );

        Widget content;
        if (width >= 1180) {
          content = SizedBox(
            height: 488,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 21, child: tarot),
                Expanded(flex: 58, child: scene),
                Expanded(flex: 21, child: oracle),
              ],
            ),
          );
        } else if (width >= 900) {
          content = Column(
            children: [
              SizedBox(height: 325, child: scene),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox(height: 350, child: tarot)),
                  Expanded(child: SizedBox(height: 350, child: oracle)),
                ],
              ),
            ],
          );
        } else {
          content = Column(
            children: [
              SizedBox(height: 325, child: scene),
              const SizedBox(height: 14),
              SizedBox(height: 350, child: tarot),
              const SizedBox(height: 14),
              SizedBox(height: 350, child: oracle),
            ],
          );
        }

        final scheme = Theme.of(context).colorScheme;
        return SingleChildScrollView(
          key: const Key('reading-atelier-page'),
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 20),
          child: Container(
            key: const Key('reading-atelier-continuous-field'),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: scheme.brightness == Brightness.dark
                    ? const [Color(0xFF161925), Color(0xFF202332)]
                    : const [Color(0xFFF8F9FC), Color(0xFFEDEFF5)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reading Atelier',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '오늘의 질문과 리딩을 위한 하나의 연속된 공간',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      recentOracleResult == null
                          ? '오늘의 장면을 천천히 열어보세요'
                          : '최근 오라클 리딩이 중앙에 머물러 있어요',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                content,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AtelierDoorway extends StatelessWidget {
  const _AtelierDoorway({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.actionKey,
    required this.icon,
    required this.alignment,
    required this.onPressed,
    this.oracleIdentity = false,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String actionLabel;
  final Key actionKey;
  final IconData icon;
  final CrossAxisAlignment alignment;
  final VoidCallback onPressed;
  final bool oracleIdentity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rightAligned = alignment == CrossAxisAlignment.end;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: rightAligned ? Alignment.centerRight : Alignment.centerLeft,
          end: rightAligned ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            scheme.primary.withValues(alpha: oracleIdentity ? 0.10 : 0.06),
            Colors.transparent,
          ],
        ),
        border: Border(
          right: rightAligned
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
          left: rightAligned
              ? BorderSide(color: scheme.outlineVariant)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (oracleIdentity)
            Transform.rotate(
              angle: 0.045,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/oracle/decks/horoscope_belline/cover/horoscope_belline_cover.jpg',
                  width: 78,
                  height: 122,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            _DoorwayCardSilhouette(icon: icon),
          const Spacer(),
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: rightAligned ? TextAlign.right : TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: rightAligned ? TextAlign.right : TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            key: actionKey,
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _DoorwayCardSilhouette extends StatelessWidget {
  const _DoorwayCardSilhouette({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 90,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-10, 3),
            child: Transform.rotate(
              angle: -0.08,
              child: _outlineCard(scheme, 0.32),
            ),
          ),
          Transform.translate(
            offset: const Offset(10, 2),
            child: Transform.rotate(
              angle: 0.08,
              child: _outlineCard(scheme, 0.24),
            ),
          ),
          Container(
            width: 67,
            height: 108,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: scheme.primary, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _outlineCard(ColorScheme scheme, double alpha) => Container(
    width: 65,
    height: 104,
    decoration: BoxDecoration(
      color: scheme.surface.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: scheme.outline.withValues(alpha: alpha)),
    ),
  );
}

class _AtelierScene extends StatelessWidget {
  const _AtelierScene({required this.result, required this.onResume});

  final OracleReadingResultSnapshot? result;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('reading-atelier-scene'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: scheme.brightness == Brightness.dark
              ? const [Color(0xFF25293A), Color(0xFF171A27)]
              : const [Color(0xFFF4F1F8), Color(0xFFE4E7EF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -54,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.12),
                  width: 28,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: result == null
                ? const _AtelierEmptyScene()
                : _AtelierRecentScene(result: result!, onResume: onResume),
          ),
        ],
      ),
    );
  }
}

class _AtelierEmptyScene extends StatelessWidget {
  const _AtelierEmptyScene();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: const Key('atelier-empty-card-stack'),
          width: 190,
          height: 194,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final item in const [(-25.0, -0.13), (25.0, 0.13)])
                Transform.translate(
                  offset: Offset(item.$1, 10),
                  child: Transform.rotate(
                    angle: item.$2,
                    child: Container(
                      width: 95,
                      height: 156,
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/oracle/decks/horoscope_belline/back/horoscope_belline_back.jpg',
                  width: 106,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          UserText.readingAtelierEmptyTitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        Text(
          UserText.readingAtelierEmptyBody,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AtelierRecentScene extends StatelessWidget {
  const _AtelierRecentScene({required this.result, required this.onResume});

  final OracleReadingResultSnapshot result;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < result.placements.length; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  result.placements[index].imageAssetPath,
                  width: result.placements.length == 1 ? 116 : 82,
                  height: result.placements.length == 1 ? 184 : 130,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text(
          UserText.readingAtelierRecentOracle,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          result.questionText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          key: const Key('atelier-resume-oracle-action'),
          onPressed: onResume,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text('다시 이어보기'),
        ),
      ],
    );
  }
}
