import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kAccessToken = 'accessToken';
  static const _kIsAuthenticated = 'isAuthenticated';
  static const _kUserEmail = 'userEmail';

  Future<void> saveSession({
    required String accessToken,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setString(_kUserEmail, email);
    await prefs.setBool(_kIsAuthenticated, true);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsAuthenticated) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kUserEmail);
    await prefs.setBool(_kIsAuthenticated, false);
  }
}
