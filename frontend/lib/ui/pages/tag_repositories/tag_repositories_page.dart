import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';
import '../../organisms/tagger_back_button.dart';
import '../../templates/repository_list.dart';
import '../../utils/tagger_page.dart';

part 'tag_repositories_controller.dart';

class TagRepositoriesPage extends TaggerPage<TagRepositoriesController> {
  const TagRepositoriesPage({Key key}) : super(key: key);

  @override
  TagRepositoriesController provider() => TagRepositoriesController();

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

    final tagName = controller.tagName.value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TaggerBackButton(),
        ),
        Expanded(
          child: RepositoryList(
            title: PageTitle('Showing tag "$tagName" related repositories'),
            onOpen: controller.openRepo,
            items: controller.repositories.value,
          ),
        ),
      ],
    );
  }
}
