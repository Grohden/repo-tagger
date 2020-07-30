import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../router.dart';
import '../../../services/session_service.dart';
import '../account/account_page.dart';
import '../starred/starred_page.dart';
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
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildSidebar(),
            Expanded(
              child: _buildPage(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final currentRoute = controller.currentRoute;

    return Sidebar(
      content: [
        SideBarButton(
          icon: const Icon(Icons.star_border),
          label: const Text('Starred repos'),
          selected: currentRoute.value == 0,
          onPressed: () => currentRoute.value = 0,
        ),
        SideBarButton(
          icon: const Icon(Icons.bookmark),
          label: const Text('Tags'),
          selected: currentRoute.value == 1,
          onPressed: () => currentRoute.value = 1,
        ),
      ],
      onLogout: controller.onLogout,
    );
  }

  Widget _buildPage() {
    final routes = [StarredPage(), AccountPage()];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: routes[controller.currentRoute.value],
    );
  }
}
