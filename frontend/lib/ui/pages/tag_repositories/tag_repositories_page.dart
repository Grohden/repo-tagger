import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';
import '../../templates/repository_list.dart';

part 'tag_repositories_bindings.dart';

part 'tag_repositories_controller.dart';

class TagRepositoriesPage extends GetView<TagRepositoriesController> {
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
