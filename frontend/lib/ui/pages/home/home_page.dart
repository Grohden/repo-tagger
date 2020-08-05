import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../templates/three_slot_container.dart';
import '../starred/starred_page.dart';
import '../tags/tags_page.dart';
import 'widgets/sidebar.dart';
import 'widgets/sidebar_button.dart';

part 'home_bindings.dart';

part 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GetX(
      init: controller,
      builder: (_) => Scaffold(
        body: SafeArea(
          child: ThreeSlotContainer(
            leftSlot: _buildSidebar(context),
            centralSlot: _buildPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final currentRoute = controller.currentRoute;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: theme.dividerTheme.thickness ?? 1,
          ),
        ),
      ),
      child: Sidebar(
        content: [
          SideBarButton(
            icon: const Icon(Icons.star_border),
            label: const Text('Starred repos'),
            selected: currentRoute.value == 0,
            onPressed: () => currentRoute.value = 0,
          ),
          SideBarButton(
            icon: const Icon(Icons.label_outline),
            label: const Text('Tags'),
            selected: currentRoute.value == 1,
            onPressed: () => currentRoute.value = 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    final routes = [
      KeyedSubtree(
        key: const ValueKey(0),
        child: StarredPage(),
      ),
      KeyedSubtree(
        key: const ValueKey(1),
        child: TagsPage(),
      ),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: routes[controller.currentRoute.value],
    );
  }
}
