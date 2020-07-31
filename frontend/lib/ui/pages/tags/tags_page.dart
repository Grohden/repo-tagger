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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const PageTitle('Current registered tags'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'jojo',
                'javascript',
                'jojo',
                'javascript',
                'jojo',
                'javascript',
                'jojo',
                'javascript',
                'jojo',
                'javascript',
                'jojo',
                'javascript',
                'jojo',
                'javascript',
                'jojo',
                'javascript',
              ].map((e) => Chip(label: Text(e))).toList(),
            )
          ],
        ),
      ),
    );
  }
}
