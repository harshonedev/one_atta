import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_points_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/loyalty_transaction_entity.dart';
import 'package:one_atta/features/profile/domain/entities/profile_update_entity.dart';
import 'package:one_atta/features/profile/domain/entities/redemption_response_entity.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart'
    hide ProfileUpdateEntity;

abstract class ProfileRepository {
  /// Get the current user's complete profile information
  /// Returns user profile with personal details, addresses, and loyalty points
  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  /// Update user profile information
  /// Only updates the fields that are provided in the ProfileUpdateEntity
  /// Automatically filters out protected fields
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    ProfileUpdateEntity profileUpdate,
  );

  /// Cache user profile data locally
  Future<Either<Failure, void>> cacheUserProfile(UserProfileEntity profile);

  /// Get cached user profile data
  Future<Either<Failure, UserProfileEntity?>> getCachedUserProfile();

  /// Clear cached profile data
  Future<Either<Failure, void>> clearCachedProfile();

  /// Loyalty Points Management

  /// Earn points from an order
  /// Awards points based on order amount and current loyalty settings
  Future<Either<Failure, LoyaltyPointsResponseEntity>> earnPointsFromOrder({
    required double amount,
    required String orderId,
  });

  /// Earn points from sharing a blend
  /// Awards fixed points when users share their custom blends
  Future<Either<Failure, LoyaltyPointsResponseEntity>> earnPointsFromShare({
    required String blendId,
  });

  /// Earn points from submitting a review
  /// Awards fixed points when users submit product/recipe reviews
  Future<Either<Failure, LoyaltyPointsResponseEntity>> earnPointsFromReview({
    required String reviewId,
  });

  /// Redeem loyalty points on an order
  /// Allows users to redeem accumulated points for discounts
  Future<Either<Failure, RedemptionResponseEntity>> redeemPoints({
    required String orderId,
    required int pointsToRedeem,
  });

  /// Get complete loyalty transaction history for the current user
  /// Returns all earning and redemption transactions
  Future<Either<Failure, List<LoyaltyTransactionEntity>>>
  getLoyaltyTransactionHistory();

  /// Cache loyalty transaction history locally
  Future<Either<Failure, void>> cacheLoyaltyHistory(
    List<LoyaltyTransactionEntity> transactions,
  );

  /// Get cached loyalty transaction history
  Future<Either<Failure, List<LoyaltyTransactionEntity>?>>
  getCachedLoyaltyHistory();

  /// Clear cached loyalty history
  Future<Either<Failure, void>> clearCachedLoyaltyHistory();
}
