part of 'home_page.dart';

class HomeBinding extends Bindings {

  @override
  void dependencies() {
    AccountBinding().dependencies();
    StarredBinding().dependencies();

    Get.lazyPut<HomeController>(() => HomeController());
  }
}