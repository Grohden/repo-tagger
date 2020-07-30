import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/api/tagger/repository_tagger_client.dart';

import '../../../services/session_service.dart';
import '../../templates/page_body.dart';

part 'account_bindings.dart';

part 'account_controller.dart';

class AccountPage extends GetView<AccountController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github tagger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: controller.logoff,
          )
        ],
      ),
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
        children: [
          ListTile(
            title: Text('User name'),
            subtitle: Text(''),
          ),
        ],
      ),
    );
  }
}
