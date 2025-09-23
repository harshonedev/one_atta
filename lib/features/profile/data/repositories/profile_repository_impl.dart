import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';
import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_points_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/profile/domain/entities/profile_update_entity.dart';
import 'package:one_atta/features/profile/domain/entities/redemption_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart'
    hide ProfileUpdateEntity;
import 'package:one_atta/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final Logger logger = Logger();

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      // Check if cached profile is fresh
      final isCacheFresh = await localDataSource.isProfileCacheFresh();
      if (isCacheFresh) {
        final cachedProfile = await localDataSource.getCachedUserProfile();
        if (cachedProfile != null) {
          logger.i('Returning cached user profile');
          return Right(cachedProfile.toEntity());
        }
      }

      // Fetch from remote if cache is not fresh or doesn't exist
      logger.i('Fetching user profile from remote');
      final result = await remoteDataSource.getUserProfile(token);

      // Cache the result
      await localDataSource.cacheUserProfile(result);

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

      // Invalidate and re-cache the updated profile
      await localDataSource.cacheUserProfile(result);

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

      final isCacheFresh = await localDataSource.isLoyaltyHistoryCacheFresh();
      if (isCacheFresh) {
        final cachedHistory = await localDataSource.getCachedLoyaltyHistory();
        if (cachedHistory != null) {
          logger.i('Returning cached loyalty history');
          return Right(cachedHistory.map((e) => e.toEntity()).toList());
        }
      }

      logger.i('Fetching loyalty history from remote');
      final user = await getUserProfile();
      return user.fold((failure) => Left(failure), (userProfile) async {
        final result = await remoteDataSource.getLoyaltyTransactionHistory(
          token: token,
          userId: userProfile.id,
        );
        await localDataSource.cacheLoyaltyHistory(result);
        return Right(result.map((e) => e.toEntity()).toList());
      });
    } on Failure catch (e) {
      logger.e('Error getting loyalty history: ${e.message}');
      return Left(e);
    } catch (e) {
      logger.e('Unexpected error getting loyalty history: $e');
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheUserProfile(
    UserProfileEntity profile,
  ) async {
    try {
      await localDataSource.cacheUserProfile(
        UserProfileModel.fromEntity(profile),
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache user profile'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity?>> getCachedUserProfile() async {
    try {
      final cachedProfile = await localDataSource.getCachedUserProfile();
      return Right(cachedProfile?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user profile'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedProfile() async {
    try {
      await localDataSource.clearCachedProfile();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cached profile'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheLoyaltyHistory(
    List<LoyaltyTransactionEntity> transactions,
  ) async {
    try {
      final models = transactions
          .map((e) => LoyaltyTransactionModel.fromEntity(e))
          .toList();
      await localDataSource.cacheLoyaltyHistory(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache loyalty history'));
    }
  }

  @override
  Future<Either<Failure, List<LoyaltyTransactionEntity>?>>
  getCachedLoyaltyHistory() async {
    try {
      final cachedHistory = await localDataSource.getCachedLoyaltyHistory();
      return Right(cachedHistory?.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached loyalty history'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedLoyaltyHistory() async {
    try {
      await localDataSource.clearCachedLoyaltyHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cached loyalty history'));
    }
  }
}
