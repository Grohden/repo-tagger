import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../molecules/load_page_error.dart';
import '../../templates/two_slot_container.dart';
import 'widets/readme_container.dart';
import 'widets/tags_container.dart';

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

    const padding = EdgeInsets.all(16.0);
    return SafeArea(
      child: TwoSlotContainer(
        leftWidth: 425,
        leftSlot: Padding(
          padding: padding,
          child: _buildLeft(context),
        ),
        rightSlot: Scrollbar(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: padding,
            child: _buildRight(context),
          ),
        ),
      ),
    );
  }

  Widget _buildRight(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final repository = controller.repository.value;

    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitle(context),
          const SizedBox(height: 16),
          Text(
            repository.description,
            style: textTheme.bodyText1,
          ),
          const SizedBox(height: 32),
          ReadmeContainer(),
        ],
      ),
    );
  }

  Widget _buildLeft(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Personal tags',
          style: textTheme.headline6,
        ),
        const SizedBox(height: 16),
        TagsContainer(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final repository = controller.repository.value;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            repository.name,
            style: textTheme.headline3,
          ),
        ),
        if (!repository.language.isNullOrBlank)
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(repository.language),
          ),
        const SizedBox(width: 8),
        Chip(
          visualDensity: VisualDensity.compact,
          label: Row(
            children: [
              const Icon(Icons.star_border, size: 14),
              const SizedBox(width: 4),
              Text(repository.stargazersCount.toString()),
            ],
          ),
        ),
      ],
    );
  }
}
