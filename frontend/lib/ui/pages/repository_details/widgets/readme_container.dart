import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

import '../repository_details_page.dart';

/// Controls exhibition of the repository readme
/// [RepositoryDetailsController] is required to be injected.
class ReadmeContainer extends GetView<RepositoryDetailsController> {
  @override
  Widget build(BuildContext context) {
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
