part of 'account_page.dart';

class AccountBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<AccountController>(() => AccountController());
  }
}