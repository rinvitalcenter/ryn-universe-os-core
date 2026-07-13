import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tarot/models/tarot_reading_result_snapshot.dart';
import 'records_tarot_card.dart';

class RecordsTarotSpreadPreview extends StatelessWidget {
  const RecordsTarotSpreadPreview({required this.snapshot, super.key});

  final TarotReadingResultSnapshot snapshot;

  bool get _isCelticCross =>
      snapshot.spreadId == 'celtic_cross' && snapshot.placements.length == 10;

  @override
  Widget build(BuildContext context) {
    final count = snapshot.placements.length;
    return Semantics(
      container: true,
      image: true,
      label: '${snapshot.spreadNameSnapshot}, $count장, 순서대로 $count개 배치 미리보기',
      child: Container(
        key: const Key('tarot-record-index-preview'),
        height: 168,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B29),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x335F6C8B)),
        ),
        child: Column(
          children: [
            if (_isCelticCross) ...[
              const Text(
                '켈틱 크로스 · 10장',
                style: TextStyle(
                  color: Color(0xFFB6BED1),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Expanded(child: _layoutForCount()),
          ],
        ),
      ),
    );
  }

  Widget _layoutForCount() {
    final count = snapshot.placements.length;
    if (count == 1) {
      return Center(
        key: const Key('tarot-record-index-preview-one'),
        child: _placement(snapshot.placements.single, width: 56),
      );
    }
    if (count <= 5) {
      return LayoutBuilder(
        key: const Key('tarot-record-index-preview-linear'),
        builder: (context, constraints) {
          final width = math.min(
            52.0,
            (constraints.maxWidth - (count - 1) * 7) / count,
          );
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < count; index++) ...[
                _placement(snapshot.placements[index], width: width),
                if (index != count - 1) const SizedBox(width: 7),
              ],
            ],
          );
        },
      );
    }
    if (_isCelticCross) {
      return _CelticCrossPreview(snapshot: snapshot);
    }
    if (count <= 7) {
      return Center(
        key: const Key('tarot-record-index-preview-multi'),
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 7,
          children: [
            for (final placement in snapshot.placements)
              _placement(placement, width: 38),
          ],
        ),
      );
    }
    return Center(
      key: const Key('tarot-record-index-preview-complex'),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 5,
        children: [
          for (final placement in snapshot.placements)
            _placement(placement, width: 30),
        ],
      ),
    );
  }

  Widget _placement(
    TarotCardPlacementSnapshot placement, {
    required double width,
  }) {
    return KeyedSubtree(
      key: Key(
        'tarot-record-index-preview-placement-${placement.placementOrder}',
      ),
      child: RecordsTarotCard(
        deckId: snapshot.deckId,
        placement: placement,
        width: width,
        showMetadata: false,
      ),
    );
  }
}

class _CelticCrossPreview extends StatelessWidget {
  const _CelticCrossPreview({required this.snapshot});

  final TarotReadingResultSnapshot snapshot;

  static const _crossPositions = <Offset>[
    Offset(.36, .48),
    Offset(.36, .48),
    Offset(.36, .04),
    Offset(.36, .92),
    Offset(.08, .48),
    Offset(.64, .48),
  ];

  @override
  Widget build(BuildContext context) {
    const cardWidth = 18.0;
    return LayoutBuilder(
      key: const Key('tarot-record-index-preview-complex'),
      builder: (context, constraints) {
        Widget placement(int index, {bool crossing = false}) {
          final card = KeyedSubtree(
            key: Key('tarot-record-index-preview-placement-${index + 1}'),
            child: RecordsTarotCard(
              deckId: snapshot.deckId,
              placement: snapshot.placements[index],
              width: cardWidth,
              showMetadata: false,
            ),
          );
          return crossing
              ? Transform.rotate(angle: math.pi / 2, child: card)
              : card;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              key: const Key('tarot-record-index-preview-celtic-cross'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var index = 0; index < 6; index++)
                    Positioned(
                      left:
                          _crossPositions[index].dx * constraints.maxWidth -
                          cardWidth / 2,
                      top:
                          _crossPositions[index].dy * constraints.maxHeight -
                          cardWidth / 0.58 / 2,
                      child: placement(index, crossing: index == 1),
                    ),
                ],
              ),
            ),
            Positioned(
              key: const Key('tarot-record-index-preview-celtic-staff'),
              right: constraints.maxWidth * .03,
              top: 0,
              bottom: 0,
              width: cardWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 9; index >= 6; index--) placement(index),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
