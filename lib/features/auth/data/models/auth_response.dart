class AuthResponse {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic> user;

  AuthResponse({required this.token, this.refreshToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refresh_token'],
      user: json['user'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': token, 'refresh_token': refreshToken, 'user': user};
  }
}
