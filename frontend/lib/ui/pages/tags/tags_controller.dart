part of 'tags_page.dart';

class TagsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;
  final hasLoadError = false.obs;
  final repos = RxList<SourceRepository>([]);

  void logoff() async {
    await Get.find<SessionService>().clearToken();
  }

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;
    try {
      await tagger.starredRepos();
//      repos.value = await tagger.userTags();
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }
}
