import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../templates/page_body.dart';

part 'account_bindings.dart';

part 'account_controller.dart';

class AccountPage extends GetView<AccountController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.showLoading.value) {
      return const CircularProgressIndicator();
    }

    return PageBody(
      child: ListView(
        children: const [
          ListTile(
            title: Text('User name'),
            subtitle: Text(''),
          ),
        ],
      ),
    );
  }
}
