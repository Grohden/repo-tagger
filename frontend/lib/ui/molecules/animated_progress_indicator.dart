import 'package:flutter/material.dart';

/// An animated circular progress indicator
/// that resizes itself depending on the [visible] flag
/// 
/// Note: this actually is always rendered (afaik)
/// but becomes zero size when [visible] is false
class AnimatedProgressIndicator extends StatelessWidget {
  const AnimatedProgressIndicator({
    @required this.child,
    this.visible = false,
  })  : assert(child != null),
        assert(visible != null);

  final Widget child;
  final bool visible;

  Widget _renderLoader() {
    final size = visible ? 20.0 : 0.0;
    final padding = visible ? 8.0 : 0.0;

    return AnimatedContainer(
      height: size,
      width: size,
      margin: EdgeInsets.only(right: padding),
      duration: const Duration(milliseconds: 300),
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _renderLoader(),
        child,
      ],
    );
  }
}
