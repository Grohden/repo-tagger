part of 'register_page.dart';

class RegisterBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}