part of 'repository_details_page.dart';

class RepositoryDetailsController extends GetxController {
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
//      repos.value = await tagger.repositoryDetail();
    } finally {
      showLoading.value = false;
    }

    scrollController.onBottomReach(() {
//      loadMore();
    }, throttleDuration: const Duration(seconds: 1));
  }
}
