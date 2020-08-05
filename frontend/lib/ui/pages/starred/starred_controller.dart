part of 'starred_page.dart';

class StarredController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final hasLoadError = false.obs;
  final showLoading = false.obs;
  final repositories = RxList<SimpleRepository>([]);

  void onInit() async {
    super.onInit();
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
}
