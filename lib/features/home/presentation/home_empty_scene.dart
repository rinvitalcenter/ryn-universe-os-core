import 'package:flutter/material.dart';

import '../../../core/text/user_text.dart';

class HomeEmptyScene extends StatelessWidget {
  const HomeEmptyScene({
    required this.onStartSelfTarot,
    this.minHeight = 520,
    super.key,
  });

  final VoidCallback onStartSelfTarot;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? const Color(0xFFF5F0E8) : const Color(0xFF20283A);
    final muted = dark ? const Color(0xFFADB2C0) : const Color(0xFF687083);

    return Container(
      key: const Key('home-empty-scene'),
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF171D30), Color(0xFF0D1322)]
              : const [Color(0xFFFFFCF6), Color(0xFFF0EDF7)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.24 : 0.07),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final narrative = _EmptyNarrative(
            foreground: foreground,
            muted: muted,
            onStartSelfTarot: onStartSelfTarot,
          );
          const subject = _JournalCardBackScene();
          return Padding(
            padding: EdgeInsets.all(compact ? 26 : 42),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      narrative,
                      const SizedBox(height: 30),
                      const SizedBox(height: 250, child: subject),
                    ],
                  )
                : _EmptyWideLayout(onStartSelfTarot: onStartSelfTarot),
          );
        },
      ),
    );
  }
}

class _EmptyWideLayout extends StatelessWidget {
  const _EmptyWideLayout({required this.onStartSelfTarot});

  final VoidCallback onStartSelfTarot;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _EmptyNarrative(
            foreground: dark
                ? const Color(0xFFF5F0E8)
                : const Color(0xFF20283A),
            muted: dark ? const Color(0xFFADB2C0) : const Color(0xFF687083),
            onStartSelfTarot: onStartSelfTarot,
          ),
        ),
        const SizedBox(width: 34),
        const Expanded(flex: 6, child: _JournalCardBackScene()),
      ],
    );
  }
}

class _EmptyNarrative extends StatelessWidget {
  const _EmptyNarrative({
    required this.foreground,
    required this.muted,
    required this.onStartSelfTarot,
  });

  final Color foreground;
  final Color muted;
  final VoidCallback onStartSelfTarot;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UserText.homeFlowEyebrow,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFC5AA70)
                : const Color(0xFF75669B),
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          UserText.homeFlowHeadline,
          style: TextStyle(
            color: foreground,
            fontSize: 38,
            height: 1.2,
            letterSpacing: -1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          UserText.homeFlowSupport,
          style: TextStyle(color: muted, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const Key('home-primary-cta'),
          onPressed: onStartSelfTarot,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text(UserText.homeStartSelfTarot),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFC1A66B)
                : const Color(0xFF35415D),
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF171A22)
                : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}

class _JournalCardBackScene extends StatelessWidget {
  const _JournalCardBackScene();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      image: true,
      label: '아직 펼치지 않은 타로 카드와 저널을 표현한 장면',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            width: 310,
            height: 210,
            child: Transform.rotate(
              angle: -0.06,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF252B3C)
                      : const Color(0xFFF7F0E5),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: dark ? 0.25 : 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.08,
            child: Container(
              width: 154,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3F4568), Color(0xFF242A47)],
                ),
                border: Border.all(color: const Color(0x66C8AD70), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.nightlight_round,
                  color: Color(0xFFD1B77D),
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 24,
            child: Icon(
              Icons.edit_outlined,
              color: dark ? const Color(0xFF8D93A6) : const Color(0xFF9A8262),
              size: 66,
            ),
          ),
        ],
      ),
    );
  }
}
