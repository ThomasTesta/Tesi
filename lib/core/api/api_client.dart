import 'package:dio/dio.dart';
import '../storage/session_store.dart';

class ApiClient {
  final Dio dio;
  final SessionStore sessionStore;

  ApiClient({
    required String baseUrl,
    required this.sessionStore,
  }) : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          // lascia true: vogliamo che Dio tiri eccezione su 400/401
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sessionStore.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // LOG request
          // ignore: avoid_print
          print('➡️ [REQ] ${options.method} ${options.baseUrl}${options.path}');
          // ignore: avoid_print
          print('   headers: ${options.headers}');
          // ignore: avoid_print
          if (options.data != null) print('   body: ${options.data}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          // LOG response
          // ignore: avoid_print
          print('✅ [RES] ${response.statusCode} ${response.requestOptions.method} '
              '${response.requestOptions.baseUrl}${response.requestOptions.path}');
          // ignore: avoid_print
          print('   data: ${response.data}');
          handler.next(response);
        },
        onError: (e, handler) async {
          // LOG error
          // ignore: avoid_print
          print('❌ [ERR] ${e.response?.statusCode} ${e.requestOptions.method} '
              '${e.requestOptions.baseUrl}${e.requestOptions.path}');
          // ignore: avoid_print
          print('   error: ${e.error}');
          // ignore: avoid_print
          print('   response: ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            await sessionStore.clear();
          }

          handler.next(e);
        },
      ),
    );
  }
}
