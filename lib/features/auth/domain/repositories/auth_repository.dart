import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/domain/entities/user.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login(AuthCredentials credentials);

  /// Register a new user
  Future<Either<Failure, User>> register(RegisterCredentials credentials);

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Send forgot password email
  Future<Either<Failure, void>> forgotPassword(
    ForgotPasswordCredentials credentials,
  );

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword(
    ResetPasswordCredentials credentials,
  );

  /// Get current user from local storage
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Refresh authentication token
  Future<Either<Failure, String>> refreshToken();

  /// Clear local storage
  Future<void> clearLocalStorage();
}
