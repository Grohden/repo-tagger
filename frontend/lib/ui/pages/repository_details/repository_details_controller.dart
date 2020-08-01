part of 'repository_details_page.dart';

class RepositoryDetailsController extends GetxController {
  RepositoryDetailsController();

  final formKey = GlobalKey<FormState>();
  final tagger = Get.find<RepositoryTaggerClient>();

  final showLoading = false.obs;
  final hasLoadError = false.obs;
  final repo = Rx<SourceRepository>(null);

  void logoff() async {
    await Get.find<SessionService>().clearToken();
  }

  void onInit() async {
    super.onInit();
    showLoading.value = true;
    hasLoadError.value = false;

    try {
      final id = int.parse(Get.parameters['id']);
      repo.value = await tagger.detailedRepo(id);
    } on Exception catch (error) {
      print(error);
      hasLoadError.value = true;
    } finally {
      showLoading.value = false;
    }
  }
}
