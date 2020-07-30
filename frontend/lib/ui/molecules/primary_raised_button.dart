import 'package:flutter/material.dart';

import './animated_progress_indicator.dart';

/// A default primary raised button, generally used
/// for submit actions on forms
class PrimaryRaisedButton extends StatelessWidget {
  const PrimaryRaisedButton({
    @required this.child,
    this.onPressed,
    this.showLoader = false,
  });

  final VoidCallback onPressed;
  final Widget child;

  /// When true, shows a [AnimatedProgressIndicator] on the
  /// left side of the text
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      visualDensity: const VisualDensity(
        vertical: VisualDensity.maximumDensity,
      ),
      color: Theme.of(context).accentColor,
      textColor: Colors.white,
      onPressed: onPressed,
      child: AnimatedProgressIndicator(
        visible: showLoader,
        child: child,
      ),
    );
  }
}
