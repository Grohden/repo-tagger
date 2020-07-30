import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../account/account_page.dart';
import '../starred/starred_page.dart';

part 'home_bindings.dart';

part 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final routes = [AccountPage(), StarredPage()];

    return GetX(
      init: controller,
      builder: (_) {
        final current = controller.currentRoute.value;

        return Scaffold(
          body: routes[current],
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) => controller.currentRoute.value = index,
            currentIndex: current,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('User'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                title: Text('Starred'),
              ),
            ],
          ),
        );
      },
    );
  }
}
