import 'package:one_atta/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> removeUser();
  Future<bool> isLoggedIn();
}
