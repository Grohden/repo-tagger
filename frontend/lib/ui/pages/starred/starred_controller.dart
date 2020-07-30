part of 'starred_page.dart';

class StarredController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final scrollController = ScrollController();

  final hasLoadError = false.obs;
  final showLoading = false.obs;
  final repos = RxList<SourceRepository>([]);

  void logoff() async {
    await Get.find<SessionService>().clearToken();
  }

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      repos.value = await tagger.starredRepos();
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }

    scrollController.onBottomReach(() {
//      loadMore();
    }, throttleDuration: const Duration(seconds: 1));
  }
}
