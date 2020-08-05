import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';
import '../../utils/tagger_page.dart';

part 'tags_controller.dart';

class TagsPage extends TaggerPage<TagsController> {
  @override
  TagsController provider() => TagsController();

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
                  (tag) => ActionChip(
                    label: Text(tag.tagName),
                    onPressed: () => controller.openTag(tag),
                  ),
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
