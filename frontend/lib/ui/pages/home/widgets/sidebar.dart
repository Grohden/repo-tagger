import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/tagger_preferences.dart';

/// Side bar showed on home route
/// it shows the given [content] and a logout button
class Sidebar extends StatelessWidget {
  const Sidebar({
    @required this.content,
  });

  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    const divider = Divider(thickness: 1);

    return ListTileTheme(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: 275,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTitle(context),
              Expanded(child: _buildMainColumn()),
              divider,
              _buildChangeTheme(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangeTheme() {
    return SwitchListTile.adaptive(
      title: const Text('Dark theme'),
      value: Get.isDarkMode,
      onChanged: (active) {
        final mode = active ? ThemeMode.dark : ThemeMode.light;
        // Theme changing is good, but this is what makes us
        // see that flutter is not really ready for web, as changing
        // theme modes causes the page to hang a little
        Get.changeThemeMode(mode);
        taggerPreferences.setThemeMode(mode);
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        'Repo Tagger',
        style: textStyle.headline4,
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
