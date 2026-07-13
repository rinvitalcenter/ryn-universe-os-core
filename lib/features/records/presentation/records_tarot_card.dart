import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tarot/data/tarot_deck_registry.dart';
import '../../tarot/models/tarot_card_definition.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';

class RecordsTarotCard extends StatelessWidget {
  const RecordsTarotCard({
    required this.deckId,
    required this.placement,
    required this.width,
    this.detail = false,
    this.showOrientation = true,
    this.showMetadata = true,
    super.key,
  });

  final String deckId;
  final TarotCardPlacementSnapshot placement;
  final double width;
  final bool detail;
  final bool showOrientation;
  final bool showMetadata;

  @override
  Widget build(BuildContext context) {
    final card = _resolveCard(deckId, placement.cardId);
    final reversed = placement.orientation == TarotCardOrientation.reversed;
    final orientation = switch (placement.orientation) {
      TarotCardOrientation.upright => '정방향',
      TarotCardOrientation.reversed => '역방향',
      TarotCardOrientation.notUsed => '방향 사용 안 함',
    };
    final fallbackKey = detail
        ? const Key('detail-card-neutral-fallback')
        : const Key('records-card-neutral-fallback');

    return Semantics(
      label:
          '${placement.placementOrder}번 ${placement.cardNameSnapshot}, ${placement.positionNameSnapshot}, $orientation',
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: width / 0.58,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(detail ? 12 : 8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: card == null
                  ? _NeutralFallback(
                      key: fallbackKey,
                      label: placement.cardNameSnapshot,
                    )
                  : Transform.rotate(
                      key: reversed
                          ? const Key('records-card-reversed-rotation')
                          : null,
                      angle: reversed ? math.pi : 0,
                      child: Image.asset(
                        card.assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _NeutralFallback(
                              key: fallbackKey,
                              label: placement.cardNameSnapshot,
                            ),
                      ),
                    ),
            ),
            if (showMetadata) const SizedBox(height: 8),
            if (showMetadata && detail)
              Text(
                '${placement.placementOrder} · ${placement.cardNameSnapshot}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
            if (showMetadata && detail) const SizedBox(height: 4),
            if (showMetadata)
              Text(
                placement.positionNameSnapshot,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            if (showMetadata && showOrientation)
              Text(
                orientation,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NeutralFallback extends StatelessWidget {
  const _NeutralFallback({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF343B50),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF0ECE4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
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
