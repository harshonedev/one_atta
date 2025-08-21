import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:one_atta/features/auth/data/models/user_model.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';
import 'package:one_atta/features/auth/domain/entities/user.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(AuthCredentials credentials) async {
    try {
      final authResponse = await remoteDataSource.login(credentials);
      final userModel = UserModel.fromJson(authResponse.user);

      // Save to local storage
      await localDataSource.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }
      await localDataSource.saveUser(userModel);
      await localDataSource.setLoggedIn(true);

      return Right(userModel);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    RegisterCredentials credentials,
  ) async {
    try {
      final authResponse = await remoteDataSource.register(credentials);
      final userModel = UserModel.fromJson(authResponse.user);

      // Save to local storage
      await localDataSource.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }
      await localDataSource.saveUser(userModel);
      await localDataSource.setLoggedIn(true);

      return Right(userModel);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        await remoteDataSource.logout(token);
      }
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      // Even if remote logout fails, clear local storage
      await localDataSource.clearAll();
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(
    ForgotPasswordCredentials credentials,
  ) async {
    try {
      await remoteDataSource.forgotPassword(credentials);
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    ResetPasswordCredentials credentials,
  ) async {
    try {
      await remoteDataSource.resetPassword(credentials);
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getUser();
      return Right(userModel);
    } catch (e) {
      return Left(CacheFailure('Failed to get current user'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(CacheFailure('No refresh token found'));
      }

      final newToken = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveToken(newToken);

      return Right(newToken);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<void> clearLocalStorage() async {
    await localDataSource.clearAll();
  }

  Failure _handleException(dynamic exception) {
    final errorMessage = exception.toString();

    if (errorMessage.contains('Network error')) {
      return NetworkFailure(errorMessage);
    } else if (errorMessage.contains('Server error') ||
        errorMessage.contains('failed:')) {
      return ServerFailure(errorMessage);
    } else {
      return ServerFailure('An unexpected error occurred');
    }
  }
}
