import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';
import 'home_empty_scene.dart';
import 'home_supporting_flow.dart';
import 'home_tarot_hero.dart';

class HomeCinematicScene extends StatelessWidget {
  const HomeCinematicScene({
    this.minSceneHeight = 520,
    required this.activeTarotResult,
    required this.onOpenRecords,
    required this.onStartSelfTarot,
    required this.onOpenPeople,
    this.onOpenResult,
    this.onHideResult,
    this.questionDisplayText,
    super.key,
  });

  final double minSceneHeight;
  final TarotReadingResultSnapshot? activeTarotResult;
  final VoidCallback onOpenRecords;
  final VoidCallback onStartSelfTarot;
  final VoidCallback onOpenPeople;
  final VoidCallback? onOpenResult;
  final VoidCallback? onHideResult;
  final String? questionDisplayText;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      key: const Key('home-cinematic-scene'),
      constraints: BoxConstraints(minHeight: minSceneHeight),
      color: colors.appCanvas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          final sceneHeight = (minSceneHeight - 86).clamp(520.0, 680.0);
          final scene = activeTarotResult == null
              ? HomeEmptyScene(
                  onStartSelfTarot: onStartSelfTarot,
                  minHeight: sceneHeight,
                )
              : HomeTarotHero(
                  snapshot: activeTarotResult!,
                  questionDisplayText: questionDisplayText,
                  onOpenRecords: onOpenRecords,
                  onOpenResult: onOpenResult ?? onOpenRecords,
                  onHideResult: onHideResult ?? () {},
                  minHeight: sceneHeight,
                );
          final supporting = HomeSupportingFlow(
            compact: !wide,
            onOpenRecords: onOpenRecords,
            onOpenPeople: onOpenPeople,
            onStartSelfTarot: onStartSelfTarot,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              wide ? 24 : 18,
              16,
              wide ? 24 : 18,
              28,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                key: const Key('home-scene-content'),
                constraints: const BoxConstraints(maxWidth: 1680),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            key: const Key('home-scene-primary'),
                            child: scene,
                          ),
                          const SizedBox(width: 20),
                          SizedBox(width: 280, child: supporting),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          scene,
                          const SizedBox(height: 18),
                          supporting,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
