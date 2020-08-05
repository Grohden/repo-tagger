import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../utils/browser.dart';
import '../repository_details_page.dart';

/// Controls exhibition of the repository readme
class ReadmeContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RepositoryDetailsController>();
    final repo = controller.repository.value;
    final readmeContents = repo.readmeContents;

    return MarkdownBody(
      data: readmeContents,
      imageDirectory: 'https://raw.githubusercontent.com',
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
      onTapLink: openUrlInNewTab,
      // Some inline HTML tags are broken
      // this is a known bug for this lib
      // https://github.com/dart-lang/markdown/issues/277
      extensionSet: md.ExtensionSet.gitHubWeb,
      styleSheet: MarkdownStyleSheet(
      ),
    );
  }
}
