part of 'starred_page.dart';

class StarredController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  int _currentPage = 1;
  final hasLoadError = false.obs;
  final showLoading = false.obs;
  final showLoadingMore = false.obs;
  final repositories = RxList<SimpleRepository>([]);

  void onInit() async {
    super.onInit();
    _currentPage = 1;
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      repositories.value = await tagger.starredRepos();
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }

  void openRepo(SimpleRepository repo) {
    Router.goToRepositoryDetails(repo.githubId);
  }

  void loadMore() async {
    try {
      showLoadingMore.value = true;
      final more = await tagger.starredRepos(page: _currentPage + 1);
      repositories.addAll(more);
      _currentPage += 1;
    } on DioError catch (error) {
      Get.dialog(
        AdaptiveDialog.alert(
          title: Text(error.message ?? 'Unknown error'),
        ),
      );
    } finally {
      showLoadingMore.value = false;
    }
  }
}
