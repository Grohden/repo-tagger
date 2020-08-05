import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/api/tagger/repository_tagger_client.dart';

import '../../../router.dart';

/// Initial page that redirects the user
/// based on the current persisted token
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    _redirect();
  }

  Future _redirect() async {
    final tagger = Get.find<RepositoryTaggerClient>();

    try {
      if (await tagger.hasSession()) {
        Router.getOffAllToHome();
      } else {
        Router.getOffAllToLogin();
      }
    } on Exception catch (error) {
      print(error);
      Router.getOffAllToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
