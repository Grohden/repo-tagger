import 'package:flutter/material.dart';

import '../../router.dart';

class TaggerBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;

    return Row(
      children: [
        const IconButton(
          icon: Icon(Icons.home),
          onPressed: Router.getOffUntilHome,
        ),
        const SizedBox(width: 8),
        Text('Repo tagger', style: style.headline5),
      ],
    );
  }
}
