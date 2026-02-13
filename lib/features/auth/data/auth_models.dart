class AuthTokenResponse {
  final String accessToken;

  AuthTokenResponse({required this.accessToken});

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token mancante nella response (access_token)');
    }
    return AuthTokenResponse(accessToken: token);
  }
}
