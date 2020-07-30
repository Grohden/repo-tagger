import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/adaptive.dart';

class AdaptiveDialogAction extends StatelessWidget {
  const AdaptiveDialogAction({@required this.onPressed, @required this.child});

  final VoidCallback onPressed;
  final Widget child;

  Widget buildMaterialAction(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: child,
    );
  }

  Widget buildCupertinoAction(BuildContext context) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (shouldUseMaterial(theme)) {
      return buildMaterialAction(context);
    } else {
      return buildCupertinoAction(context);
    }
  }
}
