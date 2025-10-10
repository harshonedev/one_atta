import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_points_response_entity.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_settings_entity.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_transaction_entity.dart';

abstract class LoyaltyRepository {
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

  /// Get complete loyalty transaction history for the current user
  /// Returns all earning and redemption transactions
  Future<Either<Failure, List<LoyaltyTransactionEntity>>>
  getLoyaltyTransactionHistory();

  /// Get loyalty program settings
  /// Returns configuration for points earning and redemption
  Future<Either<Failure, LoyaltySettingsEntity>> getLoyaltySettings();
}
