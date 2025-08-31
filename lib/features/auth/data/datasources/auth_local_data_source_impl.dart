import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/auth/data/models/user_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(tokenKey, token);
    } catch (e) {
      throw CacheFailure('Failed to save token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(tokenKey);
    } catch (e) {
      throw CacheFailure('Failed to get token: $e');
    }
  }

  @override
  Future<void> removeToken() async {
    try {
      await sharedPreferences.remove(tokenKey);
    } catch (e) {
      throw CacheFailure('Failed to remove token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(userKey, userJson);
    } catch (e) {
      throw CacheFailure('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = sharedPreferences.getString(userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw CacheFailure('Failed to get user: $e');
    }
  }

  @override
  Future<void> removeUser() async {
    try {
      await sharedPreferences.remove(userKey);
    } catch (e) {
      throw CacheFailure('Failed to remove user: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
