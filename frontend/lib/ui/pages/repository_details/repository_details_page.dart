import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/ui/molecules/load_page_error.dart';
import 'package:repo_tagger/ui/molecules/page_title.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../templates/page_body.dart';

part 'repository_details_bindings.dart';

part 'repository_details_controller.dart';

class RepositoryDetailsPage extends GetView<RepositoryDetailsController> {
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

    final textTheme = Theme.of(context).textTheme;
    final repository = controller.repo.value;

    return SafeArea(
      child: DecoratedBox(
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
        child: PageBody(
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repository.name,
                  style: textTheme.headline3,
                ),
                const SizedBox(height: 16),
                Text(
                  repository.description,
                  style: textTheme.headline6,
                ),
                const SizedBox(height: 16),
                _buildTags()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = controller.repo.value.userTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return InputChip(
                label: Text(tag.name),
                onPressed: () {},
                onDeleted: () {},
              );
            }).toList(),
          )
        else
          const Text("You don't have any tags yet")
      ],
    );
  }
}
