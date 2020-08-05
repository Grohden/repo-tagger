import 'package:flutter/material.dart';

class DetailChip extends StatelessWidget {
  const DetailChip({
    @required this.label,
    @required this.content,
  });

  final Widget label;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;
    final borderThickness = theme.dividerTheme.thickness ?? 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: borderThickness,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: borderColor,
                  width: borderThickness,
                )
              )
            ),
            child: label,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(6.0),
            constraints: const BoxConstraints(
              minWidth: 38
            ),
            child: content,
          )
        ],
      ),
    );
  }
}
