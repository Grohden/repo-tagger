import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/ui/templates/repository_list.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/detail_chip.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';
import '../../templates/page_body.dart';

part 'starred_bindings.dart';

part 'starred_controller.dart';

class StarredPage extends GetView<StarredController> {
  @override
  Widget build(BuildContext context) {
    return GetX(
      init: controller,
      builder: (_) => Scaffold(
        body: Center(
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.hasLoadError.value) {
      return const LoadPageError();
    }

    if (controller.showLoading.value) {
      return const CircularProgressIndicator();
    }

    return RepositoryList(
      title: const PageTitle('Your starred repositories'),
      onOpen: controller.openRepo,
      items: controller.repositories.value,
    );
  }
}
