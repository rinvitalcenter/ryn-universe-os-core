import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/formatters/korean_date_time_formatter.dart';
import '../../../core/text/user_text.dart';
import '../../tarot/data/tarot_deck_registry.dart';
import '../../tarot/models/tarot_card_definition.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';

class HomeTarotHero extends StatefulWidget {
  const HomeTarotHero({
    required this.snapshot,
    required this.onOpenRecords,
    required this.onOpenResult,
    required this.onHideResult,
    this.minHeight = 520,
    super.key,
  });

  final TarotReadingResultSnapshot snapshot;
  final VoidCallback onOpenRecords;
  final VoidCallback onOpenResult;
  final VoidCallback onHideResult;
  final double minHeight;

  @override
  State<HomeTarotHero> createState() => _HomeTarotHeroState();
}

class _HomeTarotHeroState extends State<HomeTarotHero> {
  bool _showFullQuestion = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final snapshot = widget.snapshot;
    return Container(
      key: const Key('home-actual-result-hero'),
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF161D32), Color(0xFF0B1120)]
              : const [Color(0xFFFFFCF5), Color(0xFFF2EDF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.28 : 0.08),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final narrative = _ResultNarrative(
            snapshot: snapshot,
            showFullQuestion: _showFullQuestion,
            onToggleQuestion: () =>
                setState(() => _showFullQuestion = !_showFullQuestion),
            onOpenRecords: widget.onOpenRecords,
            onOpenResult: widget.onOpenResult,
            onHideResult: widget.onHideResult,
          );
          final stage = HomeTarotCardStage(
            snapshot: snapshot,
            onOpenFullSpread: widget.onOpenRecords,
          );
          return Padding(
            padding: EdgeInsets.all(compact ? 24 : 38),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      narrative,
                      const SizedBox(height: 26),
                      SizedBox(height: 340, child: stage),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: 4, child: narrative),
                      const SizedBox(width: 30),
                      Expanded(flex: 6, child: stage),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _ResultNarrative extends StatelessWidget {
  const _ResultNarrative({
    required this.snapshot,
    required this.showFullQuestion,
    required this.onToggleQuestion,
    required this.onOpenRecords,
    required this.onOpenResult,
    required this.onHideResult,
  });

  final TarotReadingResultSnapshot snapshot;
  final bool showFullQuestion;
  final VoidCallback onToggleQuestion;
  final VoidCallback onOpenRecords;
  final VoidCallback onOpenResult;
  final VoidCallback onHideResult;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? const Color(0xFFF7F1E8) : const Color(0xFF20283A);
    final muted = dark ? const Color(0xFFADB3C2) : const Color(0xFF697085);
    final longQuestion = snapshot.readingQuestionText.characters.length > 48;
    final time = KoreanDateTimeFormatter.compact(snapshot.readingAt);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UserText.homeCompletedTarotEyebrow,
          style: TextStyle(
            color: dark ? const Color(0xFFC6AA70) : const Color(0xFF75669B),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          snapshot.readingQuestionText,
          maxLines: showFullQuestion ? null : 3,
          overflow: showFullQuestion ? TextOverflow.visible : TextOverflow.fade,
          style: TextStyle(
            color: foreground,
            fontSize: longQuestion ? 29 : 35,
            height: 1.25,
            letterSpacing: -1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (longQuestion)
          TextButton(
            key: const Key('home-question-expand'),
            onPressed: onToggleQuestion,
            child: Text(showFullQuestion ? '질문 접기' : '질문 전체 보기'),
          ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaPill(
              icon: Icons.style_outlined,
              label: snapshot.deckNameSnapshot,
            ),
            _MetaPill(
              icon: Icons.grid_view_rounded,
              label: snapshot.spreadNameSnapshot,
            ),
            _MetaPill(icon: Icons.schedule_rounded, label: time),
          ],
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const Key('home-primary-cta'),
          onPressed: onOpenResult,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text(UserText.homeOpenResult),
          style: FilledButton.styleFrom(
            backgroundColor: dark
                ? const Color(0xFFC1A66B)
                : const Color(0xFF303B56),
            foregroundColor: dark ? const Color(0xFF171A22) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: onOpenRecords,
              icon: const Icon(Icons.auto_stories_outlined, size: 18),
              label: const Text(UserText.homeGrowthRecords),
              style: TextButton.styleFrom(foregroundColor: muted),
            ),
            TextButton.icon(
              key: const Key('home-hide-result'),
              onPressed: onHideResult,
              icon: const Icon(Icons.visibility_off_outlined, size: 17),
              label: const Text('홈에서 닫기'),
              style: TextButton.styleFrom(foregroundColor: muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: dark ? const Color(0x331F2942) : const Color(0xAAFFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: dark ? const Color(0xFFB6BBC8) : const Color(0xFF657087),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: dark ? const Color(0xFFD8D9DF) : const Color(0xFF4D566A),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTarotCardStage extends StatelessWidget {
  const HomeTarotCardStage({
    required this.snapshot,
    required this.onOpenFullSpread,
    super.key,
  });

  final TarotReadingResultSnapshot snapshot;
  final VoidCallback onOpenFullSpread;

  @override
  Widget build(BuildContext context) {
    final placements = snapshot.placements;
    if (placements.length == 1) {
      return Center(
        key: const Key('home-card-layout-one'),
        child: SizedBox(
          width: 170,
          child: _PlacementCard(
            deckId: snapshot.deckId,
            placement: placements.single,
            width: 170,
          ),
        ),
      );
    }
    if (placements.length == 3) {
      return Center(
        key: const Key('home-card-layout-three'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var index = 0; index < placements.length; index++) ...[
              SizedBox(
                width: index == 1 ? 148 : 136,
                child: _PlacementCard(
                  deckId: snapshot.deckId,
                  placement: placements[index],
                  width: index == 1 ? 148 : 136,
                ),
              ),
              if (index != placements.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      );
    }

    return Column(
      key: const Key('home-card-layout-multi'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 9,
          runSpacing: 10,
          children: [
            for (final placement in placements)
              SizedBox(
                width: placements.length <= 7 ? 94 : 78,
                child: _PlacementCard(
                  deckId: snapshot.deckId,
                  placement: placement,
                  width: placements.length <= 7 ? 94 : 78,
                  compact: true,
                ),
              ),
          ],
        ),
        if (placements.length >= 8)
          TextButton.icon(
            onPressed: onOpenFullSpread,
            icon: const Icon(Icons.open_in_full_rounded, size: 16),
            label: const Text('전체 배열 보기'),
          ),
      ],
    );
  }
}

class _PlacementCard extends StatelessWidget {
  const _PlacementCard({
    required this.deckId,
    required this.placement,
    required this.width,
    this.compact = false,
  });

  final String deckId;
  final TarotCardPlacementSnapshot placement;
  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final card = _resolveCard(deckId, placement.cardId);
    final reversed = placement.orientation == TarotCardOrientation.reversed;
    final notUsed = placement.orientation == TarotCardOrientation.notUsed;
    final imageHeight = width / 0.58;
    final labelColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6E0D7)
        : const Color(0xFF30384A);

    return Semantics(
      label:
          '${placement.placementOrder}번 ${placement.cardNameSnapshot}, ${placement.positionNameSnapshot}, ${reversed
              ? '역방향'
              : notUsed
              ? '방향 사용 안 함'
              : '정방향'}',
      child: Column(
        key: Key('home-card-placement-${placement.placementOrder}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: imageHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 8 : 12),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF262C3A)
                  : const Color(0xFFE7E2D8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: compact ? 10 : 18,
                  offset: Offset(0, compact ? 6 : 10),
                ),
              ],
            ),
            child: card == null
                ? _NeutralCardFallback(placement: placement)
                : Transform.rotate(
                    angle: reversed ? math.pi : 0,
                    child: Image.asset(
                      card.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _NeutralCardFallback(placement: placement),
                    ),
                  ),
          ),
          SizedBox(height: compact ? 6 : 9),
          Text(
            placement.positionNameSnapshot,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: compact ? 9.5 : 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (reversed)
            Text(
              '역방향',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFC3A76D)
                    : const Color(0xFF806837),
                fontSize: compact ? 8.5 : 10,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _NeutralCardFallback extends StatelessWidget {
  const _NeutralCardFallback({required this.placement});

  final TarotCardPlacementSnapshot placement;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home-card-neutral-fallback'),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3C4359), Color(0xFF242A3A)],
        ),
      ),
      child: Center(
        child: Text(
          placement.cardNameSnapshot,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF0ECE4),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

TarotCardDefinition? _resolveCard(String deckId, String cardId) {
  for (final deck in TarotDeckRegistry.decks) {
    if (deck.deckId != deckId) continue;
    for (final card in deck.cards) {
      if (card.semanticId == cardId) return card;
    }
    return null;
  }
  return null;
}
