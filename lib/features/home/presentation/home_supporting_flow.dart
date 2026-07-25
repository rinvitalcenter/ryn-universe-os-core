import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../../../core/text/user_text.dart';

class HomeSupportingFlow extends StatelessWidget {
  const HomeSupportingFlow({
    required this.onOpenRecords,
    required this.onOpenPeople,
    required this.onStartSelfTarot,
    this.compact = false,
    super.key,
  });

  final VoidCallback onOpenRecords;
  final VoidCallback onOpenPeople;
  final VoidCallback onStartSelfTarot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _QuietDestination(
        key: const Key('home-flow-records'),
        icon: Icons.auto_stories_outlined,
        title: UserText.homeGrowthRecords,
        subtitle: '완료한 흐름을 기록에서 살펴봅니다.',
        onTap: onOpenRecords,
      ),
      _QuietDestination(
        key: const Key('home-flow-people'),
        icon: Icons.people_outline_rounded,
        title: UserText.homePeople,
        subtitle: '사람을 이해하는 작업 공간으로 갑니다.',
        onTap: onOpenPeople,
      ),
      _QuietDestination(
        key: const Key('home-flow-new-tarot'),
        icon: Icons.auto_awesome_outlined,
        title: UserText.homeNewSelfTarot,
        subtitle: '새로운 질문으로 흐름을 엽니다.',
        onTap: onStartSelfTarot,
      ),
    ];

    final colors = context.rynColors;
    return Semantics(
      container: true,
      label: '이어갈 흐름',
      child: Container(
        key: const Key('home-supporting-flow-panel'),
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 18,
          compact ? 15 : 18,
          compact ? 16 : 18,
          compact ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: colors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '이어갈 흐름',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.primaryText,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            for (var index = 0; index < items.length; index++) ...[
              items[index],
              if (index != items.length - 1)
                Divider(height: 1, color: colors.hairline),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuietDestination extends StatelessWidget {
  const _QuietDestination({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        focusColor: colors.focusRing.withValues(alpha: 0.18),
        hoverColor: colors.hoverOverlay,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colors.primaryAction),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.mutedText,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.mutedText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
