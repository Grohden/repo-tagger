import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';

part 'tags_bindings.dart';

part 'tags_controller.dart';

class TagsPage extends GetView<TagsController> {
  @override
  Widget build(BuildContext context) {
    return GetX(
      init: controller,
      builder: (_) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
            child: _buildContent(context),
          ),
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

    final tags = controller.tags.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const PageTitle('Current registered tags'),
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Chip(label: Text(tag.name))).toList(),
          )
        else
          const Text("You don't have any tags yet")
      ],
    );
  }
}
