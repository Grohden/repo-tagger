import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../extensions/scroll_controller.dart';
import '../../templates/page_body.dart';

part 'starred_bindings.dart';

part 'starred_controller.dart';

class StarredPage extends GetView<StarredController> {
  @override
  Widget build(BuildContext context) {
    return GetX(
      init: controller,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Starred repositories'),
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

    final items = controller.repos.value;
    final theme = Theme.of(context);
    final style = theme.textTheme;

    return SafeArea(
      child: ListView.separated(
          itemCount: items.length,
          padding: const EdgeInsets.all(kStandardPadding),
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: Text(item.name, style: style.headline6),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!item.description.isNullOrBlank)
                    Text(item.description ?? ''),
                  _buildChipDetails(item),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildChipDetails(SourceRepository item) {
    const spacing = SizedBox(width: 4);

    return Row(
      children: [
        // FIXME: may be confusing for the user to see this
        if (!item.language.isNullOrBlank)
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(item.language.toString()),
          ),
        spacing,
        Chip(
          visualDensity: VisualDensity.compact,
          label: Row(
            children: [
              const Icon(Icons.star_border, size: 14),
              spacing,
              Text(item.stargazersCount.toString()),
            ],
          ),
        ),
      ],
    );
  }
}
