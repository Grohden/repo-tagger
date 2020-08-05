part of 'tags_page.dart';

class TagsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;
  final hasLoadError = false.obs;
  final tags = RxList<UserTag>([]);

  void onInit() async {
    super.onInit();
    load();
  }

  void load() async {
    showLoading.value = true;
    hasLoadError.value = false;
    try {
      tags.value = await tagger.userTags();
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }

  void openTag(UserTag tag) {
    Router.goToTag(tag.tagId);
  }
}
