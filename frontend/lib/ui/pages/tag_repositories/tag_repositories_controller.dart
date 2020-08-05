part of 'tag_repositories_page.dart';

class TagRepositoriesController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final hasLoadError = false.obs;
  final showLoading = false.obs;
  final repositories = RxList<SimpleRepository>([]);
  final tagName = ''.obs;

  int get tagId => int.parse(Get.parameters['id']);

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      final data = await tagger.repositoriesByTag(tagId);
      repositories.value = data.repositories;
      tagName.value = data.tag.tagName;
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

  void getBack() {
    Router.getOffAllToHome();
  }
}
