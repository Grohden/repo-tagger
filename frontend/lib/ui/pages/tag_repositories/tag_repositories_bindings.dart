part of 'tag_repositories_page.dart';

class TagRepositoriesBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<TagRepositoriesController>(() => TagRepositoriesController());
  }
}