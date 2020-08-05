part of 'repository_details_page.dart';

typedef Predicate<T> = bool Function(T value);

Predicate<UserTag> _tagEqLower(UserTag a) =>
    (b) => a.tagName.toLowerCase() == b.tagName.toLowerCase();

class RepositoryDetailsController extends GetxController {
  RepositoryDetailsController();

  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;
  final hasLoadError = false.obs;
  final repository = Rx<DetailedRepository>(null);

  List<UserTag> _allUserTags;

  int get repoId => int.parse(Get.parameters['id']);
  
  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      repository.value = await tagger.detailedRepo(repoId);
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }

  void getBack() {
    Router.getOffAllToHome();
  }

  void openTag(UserTag tag) {
    Router.offAndToRepositories(tag.tagId);
  }

  /// Adds new tag into the current repository
  /// in case the flag name is already present
  /// at [repository] userTags this call is a noop
  Future<UserTag> addTag(UserTag tag) async {
    final foundTag = repository.value.userTags.firstWhere(
      _tagEqLower(tag),
      orElse: () => null,
    );

    try {
      // This can happen because the user
      // can type the same name and get a "add" button
      // on tag input
      if (foundTag != null) {
        return null;
      }

      return tagger.addTag(CreateTagInput(
        tagName: tag.tagName,
        repoGithubId: repoId,
      ));
    } on DioError catch (_) {
      // ignored, let's pretend we have a optimist response here.
    }

    return null;
  }

  /// Removes a tag from a repository
  /// server errors are ignored
  void removeTag(UserTag tag) async {
    try {
      tagger.removeTag(
        userTagId: tag.tagId,
        githubId: repoId,
      );
    } on DioError catch (_) {
      // ignored, let's pretend we have a optimist response here.
    }
  }

  /// Finds a tags suggestion list
  ///
  /// It uses the user tags endpoint and caches it, tags
  /// are then matched with [query] and removed if
  /// they're found on [currentTags]
  Future<List<UserTag>> findSuggestions(String query) async {
    final currentTags = repository.value.userTags;

    if (_allUserTags == null) {
      final userTags = await tagger.userTags();
      final suggestedLangTag = UserTag(
        tagId: null,
        tagName: repository.value.language,
      );
      final useLangTag = userTags.firstWhere(
        _tagEqLower(suggestedLangTag),
        orElse: () => null,
      );

      _allUserTags = [
        ...userTags,
        if (useLangTag == null) suggestedLangTag,
      ];
    }

    notInCurrentTags(UserTag tag) {
      final found = currentTags.firstWhere(
        _tagEqLower(tag),
        orElse: () => null,
      );

      return found == null;
    }

    return _allUserTags
        .where((tag) => tag.tagName.toLowerCase().contains(query.toLowerCase()))
        .where(notInCurrentTags)
        .toList();
  }
}
