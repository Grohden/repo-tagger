part of 'register_page.dart';

class RegisterController extends FormController {
  final tagger = Get.find<RepositoryTaggerClient>();
  final formKey = GlobalKey<FormState>();

  final showLoading = false.obs;

  // Controllers
  final userNameController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordController = TextEditingController();

  void openLogin() {
    if (Get.previousRoute != Routes.login) {
      Router.getOffAllToLogin();
    } else {
      Get.back();
    }
  }

  @override
  Future onSubmit() async {
    final message = await tagger.register(
      RegisterUser(
          name: userNameController.text,
          displayName: displayNameController.text,
          password: passwordController.text),
    );

    openLogin();
    Get.snackbar('Created', message);
  }
}
