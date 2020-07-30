part of 'tags_page.dart';

class TagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagsController>(
        () => TagsController());
  }
}
