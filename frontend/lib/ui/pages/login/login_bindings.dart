part of 'login_page.dart';

class LoginBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}