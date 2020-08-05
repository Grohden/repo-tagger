import 'package:flutter/material.dart';
import 'package:repo_tagger/ui/utils/tagger_page.dart';

import '../../../../api/tagger/repository_tagger_client.dart';
import '../../../../external/taggable/taggable.dart';
import '../repository_details_page.dart';

/// Controls exhibition and creation UI for user tags
/// [RepositoryDetailsController] is required to be injected.
class TagsContainer extends TaggerPage<RepositoryDetailsController> {
  @override
  RepositoryDetailsController provider() => RepositoryDetailsController();

  @override
  Widget build(BuildContext context) {
    // FIXME: underlying third party lib is applying a really
    //  nice side effect on our list here :DDDD (by removing some items of it)
    //  for now this is surprisingly.. useful (?)
    final tags = controller.repository.value.userTags;
    return FlutterTagging<UserTag>(
      initialItems: tags,
      areObjectsEqual: (a, b) => a.tagName == b.tagName,
      textFieldConfiguration: const TextFieldConfiguration(
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          labelText: 'Add a new tag',
        ),
      ),
      emptyBuilder: _buildEmptyMessage,
      findSuggestions: controller.findSuggestions,
      onAdded: controller.addTag,
      onRemoved: controller.removeTag,
      additionCallback: (query) => UserTag(tagName: query, tagId: null),
      onChipTap: controller.openTag,
      configureSuggestion: _buildSuggestion,
      configureChip: (lang) => ChipConfiguration(
        label: Text(lang.tagName),
      ),
      suggestionsBoxConfiguration: const SuggestionsBoxConfiguration(
        suggestionsBoxVerticalOffset: 10,
        keepSuggestionsOnLoading: true,
      ),
    );
  }

  Widget _buildEmptyMessage(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 8.0,
      ),
      child: Text('No Suggestion found', style: text.bodyText1),
    );
  }

  SuggestionConfiguration _buildSuggestion(UserTag tag) {
    return SuggestionConfiguration(
      title: Text(tag.tagName),
      additionWidget: const Chip(
        avatar: Icon(
          Icons.add_circle,
          color: Colors.white,
        ),
        label: Text('Add New Tag'),
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
