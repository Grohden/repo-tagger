part of 'starred_page.dart';

class StarredController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final scrollController = ScrollController();

  final showLoading = false.obs;
  final repos = RxList<SourceRepository>([]);

  void logoff() async {
    await Get.find<SessionService>().clearToken();
  }

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    try {
      repos.value = await tagger.starredRepos();
    } finally {
      showLoading.value = false;
    }

    scrollController.onBottomReach(() {
//      loadMore();
    }, throttleDuration: const Duration(seconds: 1));
  }
}
