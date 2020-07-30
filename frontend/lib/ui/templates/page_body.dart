import 'dart:math';

import 'package:flutter/material.dart';

const kStandardPadding = 12.0;

/// Represents a standard page body
/// which has a default padding and
/// is constrained to be of a defined max width
class PageBody extends StatelessWidget {
  const PageBody({this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = min(media.size.width, 600);

    return Padding(
      padding: const EdgeInsets.all(kStandardPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth.toDouble(),
        ),
        child: child,
      ),
    );
  }
}
