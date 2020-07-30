import 'package:flutter/material.dart';

/// Utility function that signalizes that something
/// may prefer material components over cupertino ones.
bool shouldUseMaterial(ThemeData theme) {
  assert(theme.platform != null);

  return true;
  switch (theme.platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return true;
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return false;
  }

  return true;
}
