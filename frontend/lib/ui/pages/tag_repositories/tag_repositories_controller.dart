part of 'tag_repositories_page.dart';

class TagRepositoriesController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final hasLoadError = false.obs;
  final showLoading = false.obs;
  final repositories = RxList<SimpleRepository>([]);

  int get tagId => int.parse(Get.parameters['id']);

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      repositories.value = await tagger.repositoriesByTag(tagId);
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }

  void openRepo(SimpleRepository repo) {
    Router.offAndToRepositoryDetails(repo.githubId);
  }
}
