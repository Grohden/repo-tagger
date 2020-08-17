import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility function that signalizes that something
/// may prefer material components over cupertino ones.
bool shouldUseMaterial(ThemeData theme) {
  assert(theme.platform != null);

  // TODO: Need to find out why [TargetPlatform] doesn't
  //  include web.
  final isWeb = GetPlatform.isWeb;
  if (isWeb) {
    return true;
  }

  // Switch to make sure we do not miss new platform.
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
