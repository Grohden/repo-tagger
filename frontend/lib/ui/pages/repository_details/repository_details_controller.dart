part of 'repository_details_page.dart';

class RepositoryDetailsController extends GetxController {
  RepositoryDetailsController();

  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;
  final hasLoadError = false.obs;
  final repo = Rx<DetailedSourceRepository>(null);

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
      repo.value = await tagger.detailedRepo(repoId);
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }


  Future<UserTag> addTag(UserTag tag) async {
    final foundTag = repo.value.userTags.firstWhere(
      (current) =>  current.name.toLowerCase() == tag.name.toLowerCase(),
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

  Future<List<UserTag>> findSuggestions(String query) async {
    final currentTags = repo.value.userTags;

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
