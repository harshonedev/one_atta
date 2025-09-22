import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';

abstract class ProfileRemoteDataSource {
  /// Get user profile from the API
  Future<UserProfileModel> getUserProfile(String token);

  /// Update user profile
  Future<UserProfileModel> updateProfile(
    String token,
    ProfileUpdateEntity profileUpdate,
  );

  /// Earn points from order
  Future<LoyaltyPointsResponseModel> earnPointsFromOrder({
    required String token,
    required double amount,
    required String orderId,
  });

  /// Earn points from sharing blend
  Future<LoyaltyPointsResponseModel> earnPointsFromShare({
    required String token,
    required String blendId,
  });

  /// Earn points from review
  Future<LoyaltyPointsResponseModel> earnPointsFromReview({
    required String token,
    required String reviewId,
  });

  /// Redeem loyalty points
  Future<RedemptionResponseModel> redeemPoints({
    required String token,
    required String orderId,
    required int pointsToRedeem,
  });

  /// Get loyalty transaction history
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactionHistory({
    required String token,
    required String userId,
  });
}
