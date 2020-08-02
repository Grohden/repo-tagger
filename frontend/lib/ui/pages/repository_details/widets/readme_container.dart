import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../molecules/load_page_error.dart';

import '../repository_details_page.dart';

/// Controls exhibition of the repository readme
/// [RepositoryDetailsController] is required to be injected.
class ReadmeContainer extends GetView<RepositoryDetailsController> {
  @override
  Widget build(BuildContext context) {
    if (controller.showReadmeLoading.value || true) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.readmeLoadError.value) {
      return const LoadPageError();
    }

    final readmeContents = controller.readmeContents.value;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.dividerColor,
            width: theme.dividerTheme.thickness ?? 1,
          )),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 32.0,
        ),
        child: MarkdownBody(
          data: readmeContents,
          extensionSet: md.ExtensionSet.gitHubWeb,
        ),
      ),
    );
  }
}
