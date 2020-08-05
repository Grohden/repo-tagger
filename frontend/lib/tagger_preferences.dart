import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePref = 'THEME_MODE';

final taggerPreferences = _TaggerPreferences();

class _TaggerPreferences {
  SharedPreferences _sharedInstance;

  Future init() async {
    _sharedInstance = await SharedPreferences.getInstance();
  }

  ThemeMode themeMode() {
    final mode = _sharedInstance.getString(_themeModePref);

    if (mode == 'dark') {
      return ThemeMode.dark;
    }

    if (mode == 'light') {
      return ThemeMode.light;
    }

    return ThemeMode.system;
  }

  Future setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.system:
        modeString = 'system';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
    }

    await _sharedInstance.setString(_themeModePref, modeString);
  }
}
