import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';
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
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error getting user profile: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
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

      logger.i('Updating user profile');
      final result = await remoteDataSource.updateProfile(token, profileUpdate);

      // Cache the updated profile
      await localDataSource.cacheUserProfile(result);

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error updating user profile: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheUserProfile(
    UserProfileEntity profile,
  ) async {
    try {
      // Create model from entity for caching
      final profileModel = UserProfileModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        mobile: profile.mobile,
        isVerified: profile.isVerified,
        isProfileComplete: profile.isProfileComplete,
        role: profile.role,
        loyaltyPoints: profile.loyaltyPoints,
        profilePicture: profile.profilePicture,
        likedRecipes: profile.likedRecipes,
        addresses: profile.addresses,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      );
      await localDataSource.cacheUserProfile(profileModel);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to cache user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity?>> getCachedUserProfile() async {
    try {
      final cachedProfile = await localDataSource.getCachedUserProfile();
      return Right(cachedProfile?.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedProfile() async {
    try {
      await localDataSource.clearCachedProfile();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cached profile: $e'));
    }
  }

  @override
  Future<Either<Failure, LoyaltyPointsResponse>> earnPointsFromOrder({
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

      // Clear cached profile to force refresh with new points
      await localDataSource.clearCachedProfile();

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error earning points from order: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, LoyaltyPointsResponse>> earnPointsFromShare({
    required String blendId,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      logger.i('Earning points from sharing blend: $blendId');
      final result = await remoteDataSource.earnPointsFromShare(
        token: token,
        blendId: blendId,
      );

      // Clear cached profile and loyalty history to force refresh
      await localDataSource.clearCachedProfile();
      await localDataSource.clearCachedLoyaltyHistory();

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error earning points from share: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, LoyaltyPointsResponse>> earnPointsFromReview({
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

      // Clear cached profile and loyalty history to force refresh
      await localDataSource.clearCachedProfile();
      await localDataSource.clearCachedLoyaltyHistory();

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error earning points from review: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, RedemptionResponse>> redeemPoints({
    required String orderId,
    required int pointsToRedeem,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        return Left(UnauthorizedFailure('User is not authenticated'));
      }

      logger.i('Redeeming points: $pointsToRedeem for order: $orderId');
      final result = await remoteDataSource.redeemPoints(
        token: token,
        orderId: orderId,
        pointsToRedeem: pointsToRedeem,
      );

      // Clear cached profile and loyalty history to force refresh
      await localDataSource.clearCachedProfile();
      await localDataSource.clearCachedLoyaltyHistory();

      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error redeeming points: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
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

      final user = await authLocalDataSource.getUser();
      if (user == null) {
        return Left(UnauthorizedFailure('User data not found'));
      }

      // Check if cached loyalty history is fresh
      final isCacheFresh = await localDataSource.isLoyaltyHistoryCacheFresh();
      if (isCacheFresh) {
        final cachedHistory = await localDataSource.getCachedLoyaltyHistory();
        if (cachedHistory != null && cachedHistory.isNotEmpty) {
          logger.i('Returning cached loyalty transaction history');
          return Right(
            cachedHistory.map((transaction) => transaction.toEntity()).toList(),
          );
        }
      }

      // Fetch from remote if cache is not fresh or doesn't exist
      logger.i('Fetching loyalty transaction history from remote');
      final result = await remoteDataSource.getLoyaltyTransactionHistory(
        token: token,
        userId: user.id,
      );

      // Cache the result
      await localDataSource.cacheLoyaltyHistory(result);

      return Right(
        result.map((transaction) => transaction.toEntity()).toList(),
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error getting loyalty transaction history: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheLoyaltyHistory(
    List<LoyaltyTransactionEntity> transactions,
  ) async {
    try {
      // Convert entities to models for caching
      final transactionModels = transactions.map((transaction) {
        return LoyaltyTransactionModel(
          id: transaction.id,
          userId: transaction.userId,
          reason: transaction.reason,
          referenceId: transaction.referenceId,
          points: transaction.points,
          description: transaction.description,
          earnedAt: transaction.earnedAt,
          redeemedAt: transaction.redeemedAt,
        );
      }).toList();

      await localDataSource.cacheLoyaltyHistory(transactionModels);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to cache loyalty history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LoyaltyTransactionEntity>?>>
  getCachedLoyaltyHistory() async {
    try {
      final cachedHistory = await localDataSource.getCachedLoyaltyHistory();
      return Right(
        cachedHistory?.map((transaction) => transaction.toEntity()).toList(),
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached loyalty history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedLoyaltyHistory() async {
    try {
      await localDataSource.clearCachedLoyaltyHistory();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cached loyalty history: $e'));
    }
  }
}
