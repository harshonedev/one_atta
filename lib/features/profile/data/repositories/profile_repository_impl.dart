import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';
import 'package:one_atta/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final Logger logger = Logger();

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      // Always fetch from remote - no cache
      logger.i('Fetching user profile from remote');
      final result = await remoteDataSource.getUserProfile(token);

      return Right(result.toEntity());
    } on Failure catch (e) {
      logger.e('Error getting user profile: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error getting user profile: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    ProfileUpdateEntity profileUpdate,
  ) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      final updateModel = ProfileUpdateModel.fromEntity(profileUpdate);
      final result = await remoteDataSource.updateProfile(token, updateModel);

      return Right(result.toEntity());
    } on Failure catch (e) {
      logger.e('Error updating profile: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error updating profile: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
