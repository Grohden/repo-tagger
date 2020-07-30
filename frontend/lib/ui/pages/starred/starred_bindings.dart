part of 'starred_page.dart';

class StarredBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<StarredController>(() => StarredController());
  }
}