import 'package:get/get.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const repoDetails = '/repository/:id';
}

class Router {
  static void goToLogin() {
    Get.toNamed(Routes.login);
  }

  static void getOffAllToLogin() {
    Get.offAllNamed(Routes.login);
  }

  /// Opens register page
  /// and may return a [RegisterUser]
  static Future<dynamic> goToRegister() async {
    return Get.toNamed(Routes.register);
  }

  static void goToHome() {
    Get.toNamed(Routes.home);
  }

  static void getOffAllToHome() {
    Get.offAllNamed(Routes.home);
  }

  static void goToRepositoryDetails(int id) {
    Get.toNamed('/repository/$id');
  }
}
