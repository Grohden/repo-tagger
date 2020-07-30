import 'package:flutter/material.dart';

/// Big
class SideBarButton extends StatelessWidget {
  const SideBarButton({
    @required this.onPressed,
    @required this.label,
    this.icon,
    this.selected = false,
  }) : assert(selected != null);

  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const iconSize = 28.0;
    final theme = Theme.of(context);
    final textStyle = Theme.of(context).textTheme.headline5;
    final color = selected ? theme.accentColor : null;

    return FlatButton(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null)
            IconTheme(
              data: theme.iconTheme.copyWith(size: iconSize, color: color),
              child: icon,
            ),
          if (icon != null) const SizedBox(width: 16),
          DefaultTextStyle(
            style: textStyle.copyWith(color: color),
            child: label,
          ),
        ],
      ),
    );
  }
}
