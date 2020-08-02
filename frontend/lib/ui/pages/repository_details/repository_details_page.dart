import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../services/session_service.dart';
import '../../molecules/load_page_error.dart';
import '../../templates/page_body.dart';
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

    final textTheme = Theme.of(context).textTheme;
    final repository = controller.repo.value;

    return SafeArea(
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
                style: textTheme.bodyText1,
              ),
              const SizedBox(height: 32),
              Text(
                'User tags',
                style: textTheme.headline6,
              ),
              const SizedBox(height: 16),
              TagsContainer()
            ],
          ),
        ),
      ),
    );
  }
}
