import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const PageTitle('Current registered tags'),
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(label: Text(tag.tagName)),
                )
                .toList(),
          )
        else
          Text(
            // ignore: lines_longer_than_80_chars
            "You don't have any tags yet, register them on your starred repos page",
            style: theme.textTheme.headline5,
          )
      ],
    );
  }
}
