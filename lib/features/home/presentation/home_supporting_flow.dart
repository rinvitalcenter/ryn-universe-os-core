import 'package:flutter/material.dart';

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
        icon: Icons.auto_stories_outlined,
        title: UserText.homeGrowthRecords,
        subtitle: '완료한 흐름을 기록에서 살펴봅니다.',
        onTap: onOpenRecords,
      ),
      _QuietDestination(
        icon: Icons.people_outline_rounded,
        title: UserText.homePeople,
        subtitle: '사람을 이해하는 작업 공간으로 갑니다.',
        onTap: onOpenPeople,
      ),
      _QuietDestination(
        icon: Icons.auto_awesome_outlined,
        title: UserText.homeNewSelfTarot,
        subtitle: '새로운 질문으로 흐름을 엽니다.',
        onTap: onStartSelfTarot,
      ),
    ];

    return Semantics(
      container: true,
      label: '이어갈 흐름',
      child: compact
          ? Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  items[index],
                  if (index != items.length - 1) const SizedBox(height: 8),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '이어갈 흐름',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                ...[
                  for (var index = 0; index < items.length; index++) ...[
                    items[index],
                    if (index != items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ],
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? const Color(0xFFF1EEE7) : const Color(0xFF273047);
    final muted = dark ? const Color(0xFFA8ADBC) : const Color(0xFF697085);

    return Material(
      color: dark
          ? const Color(0xFF181E2D).withValues(alpha: 0.72)
          : const Color(0xFFFFFDF8).withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        focusColor: dark ? const Color(0x338EA0C8) : const Color(0x182D3854),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: dark ? const Color(0xFFC0A66B) : const Color(0xFF59688C),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
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
                        color: muted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
