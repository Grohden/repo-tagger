import 'dart:async';
import 'dart:html';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repo_tagger/ui/utils/browser.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../molecules/detail_chip.dart';
import '../../molecules/load_page_error.dart';
import 'widgets/readme_container.dart';
import 'widgets/tags_container.dart';

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDescriptions(context),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRepoData(context),
                  _buildTagsManager(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoData(BuildContext context) {
    final theme = Theme.of(context);
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.dividerColor,
              width: theme.dividerTheme.thickness ?? 1,
            ),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: ReadmeContainer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsManager(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Flexible(
      child: Column(
        children: [
          Text(
            'Personal tags',
            style: textTheme.headline6,
          ),
          const SizedBox(height: 16),
          TagsContainer(),
        ],
      ),
    );
  }

  Widget _buildDescriptions(BuildContext context) {
    final repository = controller.repository.value;
    final theme = Theme.of(context);
    final style = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BackButton(onPressed: controller.getBack),
            Text('Repo tagger', style: style.headline5),
          ],
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            _buildRepositoryTitle(context),
            if (!repository.language.isNullOrBlank)
              DetailChip(
                content: Text(repository.language.toString()),
                label: const Text('Lang'),
              ),
            const SizedBox(width: 8),
            DetailChip(
              label: Row(
                children: const [
                  Icon(Icons.star_border, size: 14),
                  SizedBox(width: 8),
                  Text('Stars'),
                ],
              ),
              content: Text(repository.stargazersCount.toString()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          repository.description,
          style: style.bodyText1,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRepositoryTitle(BuildContext context) {
    final repository = controller.repository.value;
    final theme = Theme.of(context);
    final style = theme.textTheme;

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(repository.ownerName, style: style.headline5),
          Text(' / ', style: style.headline5),
          InkWell(
            onTap: () {
              openUrlInNewTab(repository.htmlUrl);
            },
            child: Text(
              repository.name,
              style: style.headline4.copyWith(
                color: theme.accentColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
