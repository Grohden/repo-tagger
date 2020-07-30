import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../router.dart';
import '../../../services/session_service.dart';

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
    final session = Get.find<SessionService>();

    if (await session.hasToken()) {
      Router.getOffAllToHome();
    } else {
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
