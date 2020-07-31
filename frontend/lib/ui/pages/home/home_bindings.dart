part of 'home_page.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    TagsBinding().dependencies();
    StarredBinding().dependencies();

    Get.lazyPut<HomeController>(() => HomeController());
  }
}
