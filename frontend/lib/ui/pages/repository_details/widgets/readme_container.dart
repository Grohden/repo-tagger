import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

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
      extensionSet: md.ExtensionSet.gitHubWeb,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
    );
  }
}
