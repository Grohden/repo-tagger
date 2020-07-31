import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'api/tagger/repository_tagger_client.dart';
import 'env.dart';
import 'router.dart';
import 'services/session_service.dart';
import 'ui/pages/home/home_page.dart' show HomeBinding, HomePage;
import 'ui/pages/login/login_page.dart' show LoginBinding, LoginPage;
import 'ui/pages/register/register_page.dart';
import 'ui/pages/splash/splash_page.dart';

void main() {
  runApp(TaggerApp());
}

class TaggerApp extends StatelessWidget {
  const TaggerApp._({
    @required this.session,
    @required this.dio,
    @required this.taggerClient,
  });

  factory TaggerApp() {
    final session = Get.put(SessionService());

    // Yes, this is a jojo reference
    final dio = Get.put(Dio())
      ..interceptors.add(InterceptorsWrapper(onError: (error) async {
        if (error.response.statusCode == HttpStatus.unauthorized) {
          final session = Get.find<SessionService>();

          await session.clearToken();
          Router.getOffAllToLogin();
        }
      }))
      ..interceptors.add(
        InterceptorsWrapper(onRequest: (options) async {
          final session = Get.find<SessionService>();
          final token = await session.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return options;
        }),
      )
      ..interceptors.add(LogInterceptor(responseBody: false));

    final tagger = Get.put(RepositoryTaggerClient(dio, baseUrl: taggerUrl));

    return TaggerApp._(
      session: session,
      dio: dio,
      taggerClient: tagger,
    );
  }

  final SessionService session;
  final Dio dio;
  final RepositoryTaggerClient taggerClient;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Github Tagger',
      themeMode: ThemeMode.dark,
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
          page: () => HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: Routes.login,
          page: () => LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: Routes.register,
          page: () => RegisterPage(),
          binding: RegisterBinding(),
        ),
      ],
    );
  }
}
