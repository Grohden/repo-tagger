import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'api/tagger/repository_tagger_cache_client.dart';
import 'api/tagger/repository_tagger_client.dart';
import 'router.dart';
import 'tagger_preferences.dart';
import 'ui/organisms/adaptive_dialog.dart';
import 'ui/pages/home/home_page.dart' show HomeController, HomePage;
import 'ui/pages/login/login_page.dart' show LoginPage;
import 'ui/pages/repository_details/repository_details_page.dart';
import 'ui/pages/splash/splash_page.dart';
import 'ui/pages/tag_repositories/tag_repositories_page.dart';
import 'ui/utils/browser.dart';

bool get _isInDebugMode {
  var inDebugMode = false;
  // Dart removes asserts on prod/release mode.
  assert(inDebugMode = true);
  return inDebugMode;
}

String getTaggerUrl() {
  if (_isInDebugMode) {
    return 'http://localhost:8080/api';
  } else {
    return '${getOriginUrl()}/api';
  }
}

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
      }));

    if (_isInDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: false));
    }

    final tagger = Get.put<RepositoryTaggerClient>(
      RepositoryTaggerCacheClient(
        delegate: RepositoryTaggerClient(
          dio,
          baseUrl: getTaggerUrl(),
        ),
      ),
    );

    // To fix issues related to
    // flutter/get url handlers we need to make sure
    // that get doesn't delete home controller.
    Get.put(HomeController());

    return TaggerApp._(
      dio: dio,
      taggerClient: tagger,
    );
  }

  final Dio dio;
  final RepositoryTaggerClient taggerClient;

  void _initSetup() async {
    await taggerPreferences.init();
    final mode = taggerPreferences.themeMode();

    Get.changeThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    _initSetup();

    return GetMaterialApp(
      title: 'Repo Tagger',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.lightBlueAccent,
      ),
      initialRoute: Routes.splash,
      getPages: [
        GetPage(
          name: Routes.splash,
          page: () => SplashPage(),
        ),
        GetPage(
          name: Routes.home,
          page: () => const HomePage(
            key: Key('home'),
          ),
        ),
        GetPage(
          name: Routes.repoDetails,
          page: () => const RepositoryDetailsPage(
            key: Key('repo-details'),
          ),
        ),
        GetPage(
          name: Routes.tagRepositories,
          page: () => const TagRepositoriesPage(
            key: Key('tag-repositories'),
          ),
        ),
        GetPage(
          name: Routes.login,
          page: () => LoginPage(),
        ),
      ],
    );
  }
}
