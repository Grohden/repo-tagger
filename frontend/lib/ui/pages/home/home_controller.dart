part of 'home_page.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  final currentRoute = 0.obs;

  void onLogout() async {
    final session = Get.find<SessionService>();

    await session.clearToken();
    Router.getOffAllToLogin();
  }
}
