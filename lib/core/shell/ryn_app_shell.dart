import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../theme/ryn_tokens.dart';
import 'ryn_adaptive_navigation_rail.dart';

class RynAppShell extends StatefulWidget {
  const RynAppShell({
    super.key,
    required this.destinations,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
    required this.utilityBar,
    required this.pageHost,
    this.navigationHidden = false,
  });

  final List<RynShellDestination> destinations;
  final String selectedDestinationId;
  final ValueChanged<String> onDestinationSelected;
  final Widget utilityBar;
  final Widget pageHost;
  final bool navigationHidden;

  @override
  State<RynAppShell> createState() => _RynAppShellState();
}

class _RynAppShellState extends State<RynAppShell> {
  final FocusNode _contentFocusNode = FocusNode(
    debugLabel: 'ryn-shell-content',
    skipTraversal: true,
  );
  Timer? _closeTimer;
  bool _pointerInside = false;
  bool _focusInside = false;
  bool _pinned = false;
  bool _temporaryPeekSuppressed = false;

  RynNavigationRailMode get _mode {
    if (_pinned) return RynNavigationRailMode.pinned;
    if (!_temporaryPeekSuppressed && (_pointerInside || _focusInside)) {
      return RynNavigationRailMode.peek;
    }
    return RynNavigationRailMode.compact;
  }

  void _setPointerInside(bool inside) {
    _closeTimer?.cancel();
    if (inside) {
      if (_pointerInside && !_temporaryPeekSuppressed) return;
      setState(() {
        _pointerInside = true;
        _temporaryPeekSuppressed = false;
      });
      return;
    }
    _closeTimer = Timer(RynTokens.shellPointerExitDelay, () {
      if (!mounted) return;
      setState(() {
        _pointerInside = false;
        _temporaryPeekSuppressed = false;
      });
    });
  }

  void _setFocusInside(bool inside) {
    if (_focusInside == inside) return;
    setState(() {
      _focusInside = inside;
      if (inside) _temporaryPeekSuppressed = false;
    });
  }

  void _togglePinned() {
    setState(() => _pinned = !_pinned);
  }

  void _dismissTemporaryPeek() {
    if (_pinned) return;
    setState(() {
      _temporaryPeekSuppressed = true;
      _focusInside = false;
    });
    _contentFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('ryn-app-shell'),
      color: context.rynColors.appCanvas,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.navigationHidden)
            RynNavigationRailFocusHost(
              child: RynAdaptiveNavigationRail(
                mode: _mode,
                destinations: widget.destinations,
                selectedDestinationId: widget.selectedDestinationId,
                onDestinationSelected: widget.onDestinationSelected,
                onPointerInsideChanged: _setPointerInside,
                onFocusInsideChanged: _setFocusInside,
                onPinToggle: _togglePinned,
                onTemporaryPeekDismissed: _dismissTemporaryPeek,
              ),
            )
          else
            const SizedBox.shrink(key: Key('ryn-navigation-hidden')),
          Expanded(
            child: Focus(
              focusNode: _contentFocusNode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Offstage(
                    offstage: widget.navigationHidden,
                    child: ExcludeFocus(
                      key: const Key('ryn-global-chrome-focus-guard'),
                      excluding: widget.navigationHidden,
                      child: ExcludeSemantics(
                        key: const Key('ryn-global-chrome-semantics-guard'),
                        excluding: widget.navigationHidden,
                        child: IgnorePointer(
                          key: const Key('ryn-global-chrome-pointer-guard'),
                          ignoring: widget.navigationHidden,
                          child: widget.utilityBar,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: widget.pageHost),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RynLazyPersistentPageHost extends StatefulWidget {
  const RynLazyPersistentPageHost({
    super.key,
    required this.selectedPageId,
    required this.pageBuilders,
  });

  final String selectedPageId;
  final Map<String, WidgetBuilder> pageBuilders;

  @override
  State<RynLazyPersistentPageHost> createState() =>
      _RynLazyPersistentPageHostState();
}

class _RynLazyPersistentPageHostState extends State<RynLazyPersistentPageHost> {
  final LinkedHashSet<String> _visited = LinkedHashSet<String>();
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _visit(widget.selectedPageId);
  }

  @override
  void didUpdateWidget(covariant RynLazyPersistentPageHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visit(widget.selectedPageId);
  }

  void _visit(String pageId) {
    assert(
      widget.pageBuilders.containsKey(pageId),
      'No page builder registered for $pageId.',
    );
    _visited.add(pageId);
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _pageStorageBucket,
      child: Stack(
        key: const Key('ryn-lazy-page-host'),
        fit: StackFit.expand,
        children: [
          for (final pageId in _visited)
            _PreservedPageSlot(
              key: ValueKey<String>('ryn-preserved-$pageId'),
              pageId: pageId,
              active: pageId == widget.selectedPageId,
              builder: widget.pageBuilders[pageId]!,
            ),
        ],
      ),
    );
  }
}

class _PreservedPageSlot extends StatelessWidget {
  const _PreservedPageSlot({
    super.key,
    required this.pageId,
    required this.active,
    required this.builder,
  });

  final String pageId;
  final bool active;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !active,
      child: TickerMode(
        key: ValueKey<String>('ryn-page-$pageId-ticker'),
        enabled: active,
        child: ExcludeFocus(
          key: ValueKey<String>('ryn-page-$pageId-focus'),
          excluding: !active,
          child: ExcludeSemantics(
            key: ValueKey<String>('ryn-page-$pageId-semantics'),
            excluding: !active,
            child: IgnorePointer(
              key: ValueKey<String>('ryn-page-$pageId-pointer'),
              ignoring: !active,
              child: KeyedSubtree(
                key: PageStorageKey<String>('ryn-page-$pageId'),
                child: Builder(builder: builder),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
