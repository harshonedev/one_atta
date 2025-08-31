import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:one_atta/features/auth/data/models/user_model.dart';
import 'package:one_atta/features/auth/domain/entities/auth_response_entity.dart';
import 'package:one_atta/features/auth/domain/entities/otp_response_entity.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, OtpResponseEntity>> sendLoginOtp(String mobile) async {
    try {
      final result = await remoteDataSource.sendLoginOtp(mobile);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> verifyLoginOtp(
    String mobile,
    String otp,
  ) async {
    try {
      final result = await remoteDataSource.verifyLoginOtp(mobile, otp);

      // Save token and user data locally
      await localDataSource.saveToken(result.token);
      await localDataSource.saveUser(result.user as UserModel);

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, OtpResponseEntity>> sendRegistrationOtp({
    required String mobile,
    required String name,
    required String email,
  }) async {
    try {
      final result = await remoteDataSource.sendRegistrationOtp(
        mobile: mobile,
        name: name,
        email: email,
      );
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> verifyRegistrationOtp({
    required String mobile,
    required String otp,
    required String name,
    required String email,
  }) async {
    try {
      final result = await remoteDataSource.verifyRegistrationOtp(
        mobile: mobile,
        otp: otp,
        name: name,
        email: email,
      );

      // Save token and user data locally
      await localDataSource.saveToken(result.token);
      await localDataSource.saveUser(result.user as UserModel);

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await localDataSource.saveToken(token);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to save token: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to get token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeToken() async {
    try {
      await localDataSource.removeToken();
      await localDataSource.removeUser();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to remove token: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user?.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status: $e'));
    }
  }
}
