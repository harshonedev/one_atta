import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveRefreshToken(String refreshToken);
  Future<void> saveUser(UserModel user);
  Future<void> setLoggedIn(bool isLoggedIn);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getUser();
  Future<bool> isLoggedIn();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveToken(String token) async {
    await sharedPreferences.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await sharedPreferences.setString(
      AppConstants.refreshTokenKey,
      refreshToken,
    );
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await sharedPreferences.setString(AppConstants.userKey, userJson);
  }

  @override
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await sharedPreferences.setBool(AppConstants.isLoggedInKey, isLoggedIn);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(AppConstants.tokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return sharedPreferences.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = sharedPreferences.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
    await sharedPreferences.remove(AppConstants.refreshTokenKey);
    await sharedPreferences.remove(AppConstants.userKey);
    await sharedPreferences.remove(AppConstants.isLoggedInKey);
  }
}
