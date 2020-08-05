import 'package:flutter/material.dart';
import 'package:repo_tagger/ui/utils/browser.dart';

import '../../../generated_env.dart';
import '../../templates/page_body.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Repo Tagger', style: text.headline4),
            PageBody(
              child: FlatButton(
                child: const Text('Login with github'),
                onPressed: _openOAuth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOAuth() {
    replaceUrl('$taggerUrl/oauth');
  }
}
