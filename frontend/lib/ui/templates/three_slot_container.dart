import 'package:flutter/material.dart';

/// Renders a tree slot (left, center, right) container
class ThreeSlotContainer extends StatelessWidget {
  const ThreeSlotContainer({
    Key key,
    this.leftSlot,
    this.rightSlot,
    @required this.centralSlot,
    this.leftWidth = 275,
    this.rightWidth = 275,
  }) : super(key: key);

  final double leftWidth;
  final Widget leftSlot;
  final double rightWidth;
  final Widget rightSlot;

  final Widget centralSlot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leftSlot != null) SizedBox(width: leftWidth, child: leftSlot),
        Expanded(child: centralSlot),
        if (rightSlot != null) SizedBox(width: rightWidth, child: rightSlot)
      ],
    );
  }
}
