part of 'login_page.dart';

class LoginController extends FormController {
  final tagger = Get.find<RepositoryTaggerClient>();
  final formKey = GlobalKey<FormState>();

  final showLoading = false.obs;

  // Controllers
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
    final registry = await Router.goToRegister();

    if (registry is RegisterUser) {
      userNameController.text = registry.name;
    }
  }

  @override
  Future onSubmit() async {
    final token = await tagger.login(UserPasswordCredential(
      name: userNameController.text,
      password: passwordController.text,
    ));

    await Get.find<SessionService>().saveToken(token);

    Router.getOffAllToHome();
  }
}
