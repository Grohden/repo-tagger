part of 'repository_details_page.dart';

class RepositoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RepositoryDetailsController>(
        () => RepositoryDetailsController());
  }
}
