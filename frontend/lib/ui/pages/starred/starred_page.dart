import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';
import '../../templates/repository_list.dart';
import '../../utils/tagger_page.dart';

part 'starred_controller.dart';

class StarredPage extends TaggerPage<StarredController> {
  @override
  StarredController provider() => StarredController();

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
