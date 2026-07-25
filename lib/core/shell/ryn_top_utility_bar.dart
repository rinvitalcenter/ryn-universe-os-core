import 'package:flutter/material.dart';

import '../theme/ryn_tokens.dart';

class RynTopUtilityBar extends StatelessWidget {
  const RynTopUtilityBar({
    super.key,
    required this.title,
    required this.themeControl,
    required this.ownerControl,
    this.contextualActions,
  });

  final String title;
  final Widget themeControl;
  final Widget ownerControl;
  final Widget? contextualActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Semantics(
      container: true,
      header: true,
      label: '전역 유틸리티',
      child: Material(
        key: const Key('ryn-top-utility-bar'),
        color: colors.raisedUtilityMaterial,
        elevation: RynTokens.elevationNone,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.hairline)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final titleWidget = Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              );
              final search = OutlinedButton.icon(
                key: const Key('ryn-global-search-coming-soon'),
                onPressed: null,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('통합 검색 · 준비 중'),
              );
              final utilities = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.end,
                children: [
                  if (!compact) search,
                  ?contextualActions,
                  themeControl,
                  ownerControl,
                ],
              );

              if (compact) {
                return Row(
                  children: [
                    Expanded(child: titleWidget),
                    const SizedBox(width: 8),
                    Flexible(child: utilities),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 16),
                  utilities,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
