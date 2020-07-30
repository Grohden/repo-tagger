part of 'account_page.dart';

class AccountController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;

  void logoff() async {
    await Get.find<SessionService>().clearToken();
  }

  @override
  void onInit() async {
    print('Init');

//    tagger.userInfo();
  }
}
