import 'dart:async';

import 'package:flutter/material.dart';

extension OnBottomReach on ScrollController {
  void onBottomReach(
    VoidCallback callback, {
    double sensitivity = 200.0,
    Duration throttleDuration,
  }) {
    final duration = throttleDuration ?? const Duration(milliseconds: 200);
    Timer timer;

    addListener(() {
      if (timer != null) {
        return;
      }

      // I used the timer to destroy the timer
      timer = Timer(duration, () => timer = null);

      final maxScroll = position.maxScrollExtent;
      final currentScroll = position.pixels;
      if (maxScroll - currentScroll <= sensitivity) {
        callback();
      }
    });
  }
}
