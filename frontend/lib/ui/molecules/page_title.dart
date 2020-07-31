import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  const PageTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        title,
        style: textStyle.headline4,
      ),
    );
  }
}
