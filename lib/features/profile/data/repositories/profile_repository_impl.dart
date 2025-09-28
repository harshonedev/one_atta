import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_points_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/profile/domain/entities/profile_update_entity.dart';
import 'package:one_atta/features/profile/domain/entities/redemption_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart'
    hide ProfileUpdateEntity;
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

  @override
  Future<Either<Failure, LoyaltyPointsResponseEntity>> earnPointsFromOrder({
    required double amount,
    required String orderId,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      logger.i('Earning points from order: $orderId, amount: $amount');
      final result = await remoteDataSource.earnPointsFromOrder(
        token: token,
        amount: amount,
        orderId: orderId,
      );
      return Right(result.toEntity());
    } on Failure catch (e) {
      logger.e('Error earning points from order: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error earning points from order: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, LoyaltyPointsResponseEntity>> earnPointsFromReview({
    required String reviewId,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      logger.i('Earning points from review: $reviewId');
      final result = await remoteDataSource.earnPointsFromReview(
        token: token,
        reviewId: reviewId,
      );
      return Right(result.toEntity());
    } on Failure catch (e) {
      logger.e('Error earning points from review: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error earning points from review: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, LoyaltyPointsResponseEntity>> earnPointsFromShare({
    required String blendId,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      logger.i('Earning points from share: $blendId');
      final result = await remoteDataSource.earnPointsFromShare(
        token: token,
        blendId: blendId,
      );
      return Right(result.toEntity());
    } on Failure catch (e) {
      logger.e('Error earning points from share: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error earning points from share: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, RedemptionResponseEntity>> redeemPoints({
    required String orderId,
    required int pointsToRedeem,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      logger.i('Redeeming $pointsToRedeem points for order: $orderId');
      final result = await remoteDataSource.redeemPoints(
        token: token,
        orderId: orderId,
        pointsToRedeem: pointsToRedeem,
      );
      return Right(result.toEntity());
    } on Failure catch (e) {
      logger.e('Error redeeming points: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error redeeming points: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<LoyaltyTransactionEntity>>>
  getLoyaltyTransactionHistory() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      // Always fetch from remote - no cache
      logger.i('Fetching loyalty history from remote');
      final user = await authLocalDataSource.getUser();
      if (user == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }
      final result = await remoteDataSource.getLoyaltyTransactionHistory(
        token: token,
        userId: user.id,
      );
      return Right(result.map((e) => e.toEntity()).toList());
    } on Failure catch (e) {
      logger.e('Error getting loyalty history: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error getting loyalty history: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
