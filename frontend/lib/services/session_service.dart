import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  String _token;
  bool _loaded = false;
  static const tokenKey = 'repo_tagger@token';

  Future<String> getToken() async {
    if (!_loaded) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(tokenKey);
      _loaded = true;
    }

    return _token;
  }

  Future saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);
    _token = token;
  }

  Future<bool> hasToken() async => await getToken() != null;

  Future clearToken() => saveToken(null);
}
