import 'package:flutter/material.dart';

import 'sidebar_button.dart';

/// Side bar showed on home route
/// it shows the given [content] and a logout button
class Sidebar extends StatelessWidget {
  const Sidebar({
    @required this.content,
    @required this.onLogout,
  });

  final List<Widget> content;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      child: SizedBox(
        width: 275,
        child: Column(
          children: [
            Expanded(child: _buildMainColumn()),
            SideBarButton(
              // TODO: find out a good icon for this one
              label: const Text('Logout'),
              onPressed: onLogout,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainColumn() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: content,
    );
  }
}
