// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is but a copy from flutter gallery
// https://github.com/flutter/gallery/tree/master/lib/studies/rally
// I've only changed bit's of it.
import 'package:flutter/material.dart';

import '../../utils/display.dart';
import '../starred/starred_page.dart';
import '../tags/tags_page.dart';

const int tabCount = 2;
const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCount, vsync: this)
      ..addListener(() {
        // Set state to make sure that the [_SimpleTab] widgets
        // get updated when changing tabs.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = isDisplayDesktop(context);
    final tabBarView =
        isDesktop ? _buildDesktopBar(context) : _buildMobileBar(context);

    return Scaffold(
      body: SafeArea(
        // For desktop layout we do not want to have SafeArea at the top and
        // bottom to display 100% height content on the accounts view.
        top: !isDesktop,
        bottom: !isDesktop,
        child: Theme(
          // This theme effectively removes the default visual touch
          // feedback for tapping a tab, which is replaced with a custom
          // animation.
          data: theme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: tabBarView,
          ),
        ),
      ),
    );
  }

  Column _buildMobileBar(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
        _SimpleTabBar(
          tabs: _buildTabs(context: context, theme: theme),
          tabController: _tabController,
        ),
      ],
    );
  }

  Widget _buildDesktopBar(BuildContext context) {
    final theme = Theme.of(context);
    const verticalRotation = turnsToRotateRight;
    const revertVerticalRotation = turnsToRotateLeft;

    return Row(
      children: [
        Container(
          width: 200,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ExcludeSemantics(
                child: SizedBox(
                  height: 80,
                  child: Column(
                    children: [
                      Text('Repo tagger', style: theme.textTheme.subtitle1),
                      const SizedBox(height: 8),
                      const Icon(Icons.loyalty, size: 48),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Rotate the tab bar, so the animation is vertical for desktops.
              RotatedBox(
                quarterTurns: verticalRotation,
                child: _SimpleTabBar(
                  tabs: _buildTabs(
                    context: context,
                    theme: theme,
                    isVertical: true,
                  ).map(
                    (widget) {
                      // Revert the rotation on the tabs.
                      return RotatedBox(
                        quarterTurns: revertVerticalRotation,
                        child: widget,
                      );
                    },
                  ).toList(),
                  tabController: _tabController,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          // Rotate the tab views so we can swipe up and down.
          child: RotatedBox(
            quarterTurns: verticalRotation,
            child: TabBarView(
              controller: _tabController,
              children: _buildTabViews().map(
                (widget) {
                  // Revert the rotation on the tab views.
                  return RotatedBox(
                    quarterTurns: revertVerticalRotation,
                    child: widget,
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabs({
    BuildContext context,
    ThemeData theme,
    bool isVertical = false,
  }) {
    return [
      _SimpleTab(
        theme: theme,
        iconData: Icons.star_border,
        title: 'Starred repos',
        tabIndex: 0,
        tabController: _tabController,
        isVertical: isVertical,
      ),
      _SimpleTab(
        theme: theme,
        iconData: Icons.label_outline,
        title: 'Tags',
        tabIndex: 1,
        tabController: _tabController,
        isVertical: isVertical,
      ),
    ];
  }

  List<Widget> _buildTabViews() {
    return const [
      StarredPage(),
      TagsPage(),
    ];
  }
}

class _SimpleTabBar extends StatelessWidget {
  const _SimpleTabBar({Key key, this.tabs, this.tabController})
      : super(key: key);

  final List<Widget> tabs;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: TabBar(
        // Setting isScrollable to true prevents the tabs from being
        // wrapped in [Expanded] widgets, which allows for more
        // flexible sizes and size animations among tabs.
        isScrollable: true,
        labelPadding: EdgeInsets.zero,
        tabs: tabs,
        controller: tabController,
        // This hides the tab indicator.
        indicatorColor: Colors.transparent,
      ),
    );
  }
}

class _SimpleTab extends StatefulWidget {
  _SimpleTab({
    ThemeData theme,
    IconData iconData,
    String title,
    int tabIndex,
    TabController tabController,
    this.isVertical,
  })  : titleText = Text(title, style: theme.textTheme.button),
        isExpanded = tabController.index == tabIndex,
        icon = Icon(iconData, semanticLabel: title);

  final Text titleText;
  final Icon icon;
  final bool isExpanded;
  final bool isVertical;

  @override
  _SimpleTabState createState() => _SimpleTabState();
}

class _SimpleTabState extends State<_SimpleTab>
    with SingleTickerProviderStateMixin {
  Animation<double> _titleSizeAnimation;
  Animation<double> _titleFadeAnimation;
  Animation<double> _iconFadeAnimation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _titleSizeAnimation = _controller.view;
    _titleFadeAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
    _iconFadeAnimation = _controller.drive(Tween<double>(begin: 0.6, end: 1));
    if (widget.isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_SimpleTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Column(
        children: [
          const SizedBox(height: 18),
          FadeTransition(
            child: widget.icon,
            opacity: _iconFadeAnimation,
          ),
          const SizedBox(height: 12),
          FadeTransition(
            child: SizeTransition(
              child: Center(child: ExcludeSemantics(child: widget.titleText)),
              axis: Axis.vertical,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
            ),
            opacity: _titleFadeAnimation,
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Calculate the width of each unexpanded tab by counting the number of
    // units and dividing it into the screen width. Each unexpanded tab is 1
    // unit, and there is always 1 expanded tab which is 1 unit + any extra
    // space determined by the multiplier.
    final width = MediaQuery.of(context).size.width;
    const expandedTitleWidthMultiplier = 2;
    final unitWidth = width / (tabCount + expandedTitleWidthMultiplier);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          FadeTransition(
            child: SizedBox(
              width: unitWidth,
              child: widget.icon,
            ),
            opacity: _iconFadeAnimation,
          ),
          FadeTransition(
            child: SizeTransition(
              child: SizedBox(
                width: unitWidth * expandedTitleWidthMultiplier,
                child: Center(
                  child: ExcludeSemantics(child: widget.titleText),
                ),
              ),
              axis: Axis.horizontal,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
            ),
            opacity: _titleFadeAnimation,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
