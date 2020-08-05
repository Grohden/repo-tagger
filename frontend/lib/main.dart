import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'api/tagger/repository_tagger_client.dart';
import 'generated_env.dart';
import 'router.dart';
import 'ui/organisms/adaptive_dialog.dart';
import 'ui/pages/home/home_page.dart' show HomeBinding, HomePage;
import 'ui/pages/login/login_page.dart' show LoginBinding, LoginPage;
import 'ui/pages/repository_details/repository_details_page.dart';
import 'ui/pages/splash/splash_page.dart';
import 'ui/pages/tag_repositories/tag_repositories_page.dart';

void main() {
  runApp(TaggerApp());
}

class TaggerApp extends StatelessWidget {
  const TaggerApp._({
    @required this.dio,
    @required this.taggerClient,
  });

  /// This factory constructor
  /// is a trick to put global dependencies
  /// on get
  factory TaggerApp() {
    // Yes, this is a jojo reference
    final dio = Get.put(Dio())
      ..interceptors.add(InterceptorsWrapper(onRequest: (options) async {
        // It took me more than 16 hours to find this flag.
        // This enables all dev requests to work with cookies so our dev
        // sessions are actually persisted even when running
        // on different ports.
        // I'm almost crying right now.
        options.extra['withCredentials'] = true;

        return options;
      }))
      ..interceptors.add(InterceptorsWrapper(onError: (error) async {
        if (error.response.statusCode == HttpStatus.unauthorized) {
          // Order matters here, a dialog is a route for flutter
          // so showing one and getting off all routes will
          // do nothing besides going to another route.
          Router.getOffAllToLogin();
          Get.dialog(AdaptiveDialog.alert(
            title: const Text('Log in required'),
            content: const Text('Your session is not valid anymore'),
          ));
        }
      }))
      ..interceptors.add(LogInterceptor(responseBody: false));

    final tagger = Get.put(RepositoryTaggerClient(dio, baseUrl: taggerUrl));

    return TaggerApp._(
      dio: dio,
      taggerClient: tagger,
    );
  }

  final Dio dio;
  final RepositoryTaggerClient taggerClient;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Repo Tagger',
      themeMode: ThemeMode.dark,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.lightBlueAccent,
      ),
      initialRoute: Routes.splash,
      navigatorKey: Get.key,
      getPages: [
        GetPage(
          name: Routes.splash,
          page: () => SplashPage(),
        ),
        GetPage(
          name: Routes.home,
          page: () => HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: Routes.repoDetails,
          page: () => RepositoryDetailsPage(),
          binding: RepositoryDetailsBinding(),
        ),
        GetPage(
          name: Routes.tagRepositories,
          page: () => TagRepositoriesPage(),
          binding: TagRepositoriesBinding(),
        ),
        GetPage(
          name: Routes.login,
          page: () => LoginPage(),
        ),
      ],
    );
  }
}
