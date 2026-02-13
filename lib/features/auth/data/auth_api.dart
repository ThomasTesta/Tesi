import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import 'auth_models.dart';

class AuthApi {
  final ApiClient client;
  AuthApi(this.client);

  Future<AuthTokenResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final res = await client.dio.post(
      Endpoints.authRegister,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    );

    if (res.data is! Map<String, dynamic>) {
      throw Exception('Risposta register non valida: ${res.data}');
    }
    return AuthTokenResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthTokenResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await client.dio.post(
      Endpoints.authLogin,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    if (res.data is! Map<String, dynamic>) {
      throw Exception('Risposta login non valida: ${res.data}');
    }
    return AuthTokenResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> me() async {
    final res = await client.dio.get(Endpoints.authMe);
    if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
    throw Exception('Risposta /auth/me non valida: ${res.data}');
  }

  /// Utility per estrarre il messaggio backend in modo “umano”
  static String extractErrorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data != null) return data.toString();
      return 'HTTP ${e.response?.statusCode ?? ''}';
    }
    return e.toString();
  }
}
