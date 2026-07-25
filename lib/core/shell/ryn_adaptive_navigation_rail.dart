import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ryn_tokens.dart';

enum RynNavigationRailMode { compact, peek, pinned }

@immutable
final class RynShellDestination {
  const RynShellDestination({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class RynAdaptiveNavigationRail extends StatelessWidget {
  const RynAdaptiveNavigationRail({
    super.key,
    required this.mode,
    required this.destinations,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
    required this.onPointerInsideChanged,
    required this.onFocusInsideChanged,
    required this.onPinToggle,
    required this.onTemporaryPeekDismissed,
  });

  final RynNavigationRailMode mode;
  final List<RynShellDestination> destinations;
  final String selectedDestinationId;
  final ValueChanged<String> onDestinationSelected;
  final ValueChanged<bool> onPointerInsideChanged;
  final ValueChanged<bool> onFocusInsideChanged;
  final VoidCallback onPinToggle;
  final VoidCallback onTemporaryPeekDismissed;

  bool get _expanded => mode != RynNavigationRailMode.compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reducedMotion
        ? RynTokens.motionInstant
        : RynTokens.motionStandard;
    final width = _expanded
        ? RynTokens.shellRailExpandedWidth
        : RynTokens.shellRailCompactWidth;

    return MouseRegion(
      onEnter: (_) => onPointerInsideChanged(true),
      onExit: (_) => onPointerInsideChanged(false),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: onFocusInsideChanged,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape &&
              mode == RynNavigationRailMode.peek) {
            onTemporaryPeekDismissed();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: AnimatedContainer(
          key: const Key('ryn-navigation-rail'),
          width: width,
          duration: duration,
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: colors.raisedUtilityMaterial,
            border: Border(right: BorderSide(color: colors.hairline)),
          ),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: width,
            maxWidth: width,
            child: KeyedSubtree(
              key: Key('ryn-rail-mode-${mode.name}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RailBrand(expanded: _expanded),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        key: const Key('ryn-navigation-destination-list'),
                        padding: EdgeInsets.zero,
                        itemCount: destinations.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final destination = destinations[index];
                          return _RailDestinationTile(
                            destination: destination,
                            expanded: _expanded,
                            selected: destination.id == selectedDestinationId,
                            previousFocusNode: index == 0
                                ? null
                                : _destinationFocusNode(context, index - 1),
                            nextFocusNode: index == destinations.length - 1
                                ? null
                                : _destinationFocusNode(context, index + 1),
                            firstFocusNode: _destinationFocusNode(context, 0),
                            lastFocusNode: _destinationFocusNode(
                              context,
                              destinations.length - 1,
                            ),
                            focusNode: _destinationFocusNode(context, index),
                            onSelected: () =>
                                onDestinationSelected(destination.id),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Tooltip(
                      message: mode == RynNavigationRailMode.pinned
                          ? '내비게이션 고정 해제'
                          : '내비게이션 고정',
                      waitDuration: RynTokens.shellTooltipDelay,
                      child: Semantics(
                        button: true,
                        label: mode == RynNavigationRailMode.pinned
                            ? '내비게이션 고정 해제'
                            : '내비게이션 고정',
                        child: SizedBox(
                          height: RynTokens.shellNavigationTarget,
                          child: IconButton(
                            key: const Key('ryn-rail-pin-toggle'),
                            onPressed: onPinToggle,
                            icon: Icon(
                              mode == RynNavigationRailMode.pinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  FocusNode _destinationFocusNode(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_RailFocusNodesState>();
    assert(
      state != null,
      'RynAdaptiveNavigationRail requires rail focus nodes.',
    );
    return state!.nodeAt(index, destinations.length);
  }
}

class RynNavigationRailFocusHost extends StatefulWidget {
  const RynNavigationRailFocusHost({super.key, required this.child});

  final Widget child;

  @override
  State<RynNavigationRailFocusHost> createState() => _RailFocusNodesState();
}

class _RailFocusNodesState extends State<RynNavigationRailFocusHost> {
  final List<FocusNode> _nodes = [];

  FocusNode nodeAt(int index, int length) {
    while (_nodes.length < length) {
      _nodes.add(
        FocusNode(debugLabel: 'ryn-shell-destination-${_nodes.length}'),
      );
    }
    return _nodes[index];
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _RailBrand extends StatelessWidget {
  const _RailBrand({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return SizedBox(
      height: RynTokens.shellNavigationTarget,
      child: Row(
        children: [
          SizedBox(
            width: RynTokens.shellNavigationTarget,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.selectedState,
                  borderRadius: BorderRadius.circular(RynTokens.radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.blur_on_rounded,
                    size: 20,
                    color: colors.primaryAction,
                  ),
                ),
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ryn Universe',
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RailDestinationTile extends StatefulWidget {
  const _RailDestinationTile({
    required this.destination,
    required this.expanded,
    required this.selected,
    required this.focusNode,
    required this.previousFocusNode,
    required this.nextFocusNode,
    required this.firstFocusNode,
    required this.lastFocusNode,
    required this.onSelected,
  });

  final RynShellDestination destination;
  final bool expanded;
  final bool selected;
  final FocusNode focusNode;
  final FocusNode? previousFocusNode;
  final FocusNode? nextFocusNode;
  final FocusNode firstFocusNode;
  final FocusNode lastFocusNode;
  final VoidCallback onSelected;

  @override
  State<_RailDestinationTile> createState() => _RailDestinationTileState();
}

class _RailDestinationTileState extends State<_RailDestinationTile> {
  bool _focused = false;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      (widget.previousFocusNode ?? widget.lastFocusNode).requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      (widget.nextFocusNode ?? widget.firstFocusNode).requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      widget.firstFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      widget.lastFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onSelected();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final selected = widget.selected;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reducedMotion
        ? RynTokens.motionInstant
        : RynTokens.motionShort;
    final labelDuration = reducedMotion
        ? RynTokens.motionInstant
        : RynTokens.shellLabelDuration;
    final content = Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: _handleKey,
      child: Semantics(
        key: Key('ryn-nav-${widget.destination.id}'),
        button: true,
        selected: selected,
        label: widget.destination.label,
        child: AnimatedContainer(
          key: selected
              ? Key('ryn-nav-${widget.destination.id}-selected')
              : null,
          duration: duration,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(
            minHeight: RynTokens.shellNavigationTarget,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.selectedState : Colors.transparent,
            borderRadius: BorderRadius.circular(RynTokens.radiusMd),
            border: Border.all(
              color: _focused ? colors.focusRing : Colors.transparent,
              width: _focused ? RynTokens.shellFocusWidth : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              canRequestFocus: false,
              onTap: widget.onSelected,
              borderRadius: BorderRadius.circular(RynTokens.radiusMd),
              hoverColor: colors.hoverOverlay,
              highlightColor: colors.pressedOverlay,
              child: SizedBox(
                height: RynTokens.shellNavigationTarget,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: RynTokens.shellNavigationTarget,
                      height: RynTokens.shellNavigationTarget,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (selected)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 3,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colors.primaryAction,
                                  borderRadius: BorderRadius.circular(
                                    RynTokens.radiusXs,
                                  ),
                                ),
                              ),
                            ),
                          Icon(
                            widget.destination.icon,
                            color: selected
                                ? colors.primaryAction
                                : colors.secondaryText,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: RynTokens.shellNavigationTarget + 10,
                      width: 150,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        ignoring: !widget.expanded,
                        child: AnimatedOpacity(
                          key: Key(
                            'ryn-nav-${widget.destination.id}-label-opacity',
                          ),
                          opacity: widget.expanded ? 1 : 0,
                          duration: labelDuration,
                          curve: Curves.easeOutCubic,
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey<bool>(widget.expanded),
                            tween: Tween<double>(
                              begin: widget.expanded
                                  ? RynTokens.shellLabelSlide
                                  : 0,
                              end: widget.expanded
                                  ? 0
                                  : RynTokens.shellLabelSlide,
                            ),
                            duration: labelDuration,
                            curve: Curves.easeOutCubic,
                            builder: (context, offset, child) =>
                                Transform.translate(
                                  key: Key(
                                    'ryn-nav-${widget.destination.id}-label-slide',
                                  ),
                                  offset: Offset(offset, 0),
                                  child: child,
                                ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: selected
                                          ? colors.primaryAction
                                          : colors.primaryText,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Tooltip(
      message: widget.destination.label,
      waitDuration: RynTokens.shellTooltipDelay,
      child: content,
    );
  }
}
