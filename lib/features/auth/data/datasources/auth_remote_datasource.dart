import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/features/auth/data/models/auth_response.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(AuthCredentials credentials);
  Future<AuthResponse> register(RegisterCredentials credentials);
  Future<void> logout(String token);
  Future<void> forgotPassword(ForgotPasswordCredentials credentials);
  Future<void> resetPassword(ResetPasswordCredentials credentials);
  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthResponse> login(AuthCredentials credentials) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': credentials.email,
          'password': credentials.password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<AuthResponse> register(RegisterCredentials credentials) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': credentials.email,
          'password': credentials.password,
          'name': credentials.name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.logout),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Logout failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordCredentials credentials) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': credentials.email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Forgot password failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordCredentials credentials) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.resetPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': credentials.token,
          'password': credentials.newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Reset password failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['access_token'] ?? '';
      } else {
        throw Exception('Token refresh failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
