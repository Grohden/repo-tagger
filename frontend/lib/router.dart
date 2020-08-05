import 'package:get/get.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const repoDetails = '/repository/:id';
  static const tagRepositories = '/tag/:id';
}

class Router {
  static void goToLogin() {
    Get.toNamed(Routes.login);
  }

  static void getOffAllToLogin() {
    Get.offAllNamed(Routes.login);
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

  static void offAndToRepositoryDetails(int id) {
    Get.offAndToNamed('/repository/$id');
  }

  static void offAndToRepositories(int id) {
    Get.offAndToNamed('/tag/$id');
  }
}
