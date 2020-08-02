import 'package:flutter/material.dart';

/// Renders a two slot (left, right) container
class TwoSlotContainer extends StatelessWidget {
  const TwoSlotContainer({
    Key key,
    @required this.leftSlot,
    @required this.rightSlot,
    this.leftWidth = 275,
  }) : super(key: key);

  /// Amount of space taken by left container
  final double leftWidth;

  /// Left container takes the [leftWidth] space
  /// left container is also rendered with a right border
  /// with thickness defined by [dividerTheme]
  final Widget leftSlot;

  /// Left container takes available space left by the [leftSlot]
  final Widget rightSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: theme.dividerColor,
                width: theme.dividerTheme.thickness ?? 1,
              ),
            ),
          ),
          child: SizedBox(width: leftWidth, child: leftSlot),
        ),
        Expanded(child: rightSlot)
      ],
    );
  }
}
