import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../extensions/scroll_controller.dart';

part 'repository_details_bindings.dart';

part 'repository_details_controller.dart';

class RepositoryDetailsPage extends GetView<RepositoryDetailsController> {
  @override
  Widget build(BuildContext context) {
    return GetX(
      init: controller,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('RepositoryDetails repositories'),
        ),
        body: Center(
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.showLoading.value) {
      return const CircularProgressIndicator();
    }

    return const SafeArea(
      child: Text(''),
    );
  }
}
