import 'package:flutter/material.dart';

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: const Key('home-cinematic-scene'),
      constraints: BoxConstraints(minHeight: minSceneHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF111623), Color(0xFF0D1220)]
              : const [Color(0xFFF7F5F0), Color(0xFFFAF9F6)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1180;
          final sceneHeight = (constraints.minHeight - 46).clamp(520.0, 1600.0);
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
              wide ? 26 : 18,
              18,
              wide ? 26 : 18,
              28,
            ),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 76, child: scene),
                      const SizedBox(width: 20),
                      SizedBox(width: 250, child: supporting),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [scene, const SizedBox(height: 18), supporting],
                  ),
          );
        },
      ),
    );
  }
}
