import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/ui/templates/repository_list.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/load_page_error.dart';
import '../../molecules/page_title.dart';
import '../../templates/page_body.dart';

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

  Widget _buildList(List<SimpleRepository> items, TextTheme style) {
    return ListView.separated(
        itemCount: items.length,
        padding: const EdgeInsets.all(kStandardPadding),
        separatorBuilder: (_, __) => const Divider(thickness: 1),
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            onTap: () => controller.openRepo(item),
            title: Text(item.name, style: style.headline6),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description?.isNotEmpty == true)
                  Text(item.description ?? ''),
                _buildChipDetails(item),
              ],
            ),
          );
        });
  }

  Widget _buildChipDetails(SimpleRepository item) {
    const spacing = SizedBox(width: 4);

    return Row(
      children: [
        if (item.language?.isNotEmpty == true)
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
