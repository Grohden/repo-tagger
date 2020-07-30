import 'package:flutter/material.dart';

/// Shows a standard error message
class LoadPageError extends StatelessWidget {
  const LoadPageError({
    this.message = 'Could not load page :(',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Text(message, style: theme.headline6);
  }
}
