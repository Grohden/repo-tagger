part of 'repository_details_page.dart';

class RepositoryDetailsController extends GetxController {
  RepositoryDetailsController();

  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;
  final hasLoadError = false.obs;
  final repository = Rx<DetailedSourceRepository>(null);

  final showReadmeLoading = false.obs;
  final readmeLoadError = false.obs;
  final readmeContents = ''.obs;

  List<UserTag> _allUserTags;

  void logoff() async {
    await Get.find<SessionService>().clearToken();
  }

  int get repoId => int.parse(Get.parameters['id']);

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      repository.value = await tagger.detailedRepo(repoId);

      // Theoretically we should'nt need to await readme load
      // but this **provably** causes a race condition
      // on get set state fn
      await loadReadme();
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }

  /// Loads the readme contents from the repository,
  /// may fail for unknown reasons, and in that case
  /// it flags [readmeLoadError] as true
  Future loadReadme() async {
    try {
      showReadmeLoading.value = true;
      readmeLoadError.value = false;
      print(repository.value.readmeUrl);

      // We don't want to use the app dio instance
      // because it's meant to be used with repository tagger
      // and adds some unnecessary interceptors
      final response = await Dio().get<String>(repository.value.readmeUrl);

      readmeContents.value = response.data;
    } on DioError catch (error) {
      readmeLoadError.value = true;
      print(error);
    } finally {
      showReadmeLoading.value = false;
    }
  }

  /// Adds new tag into the current repository
  /// in case the flag name is already present
  /// at [repository] userTags this call is a noop
  Future<UserTag> addTag(UserTag tag) async {
    final foundTag = repository.value.userTags.firstWhere(
      (current) => current.name.toLowerCase() == tag.name.toLowerCase(),
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
        tagName: tag.name,
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
        userTagId: tag.id,
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
      _allUserTags = await tagger.userTags();
    }

    notInCurrentTags(UserTag tag) {
      final found = currentTags.firstWhere(
        (present) => tag.name == present.name,
        orElse: () => null,
      );

      return found == null;
    }

    return _allUserTags
        .where((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        .where(notInCurrentTags)
        .toList();
  }
}
