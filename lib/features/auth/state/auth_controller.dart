import 'package:flutter/material.dart';
import '../../../core/storage/session_store.dart';
import '../data/auth_api.dart';

class AuthController extends ChangeNotifier {
  final AuthApi api;
  final SessionStore store;

  AuthController({required this.api, required this.store});

  bool loading = false;
  String? error;

  Future<void> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final tokenRes = await api.login(email: email, password: password);
      await store.saveSession(accessToken: tokenRes.accessToken, email: email);
    } catch (e) {
      error = AuthApi.extractErrorMessage(e);
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> registerAndLogin({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final tokenRes = await api.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      await store.saveSession(accessToken: tokenRes.accessToken, email: email);
    } catch (e) {
      error = AuthApi.extractErrorMessage(e);
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await store.clear();
    notifyListeners();
  }
}
