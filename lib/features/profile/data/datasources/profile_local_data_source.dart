import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  /// Cache user profile data
  Future<void> cacheUserProfile(UserProfileModel profile);

  /// Get cached user profile data
  Future<UserProfileModel?> getCachedUserProfile();

  /// Clear cached profile data
  Future<void> clearCachedProfile();

  /// Cache loyalty transaction history
  Future<void> cacheLoyaltyHistory(List<LoyaltyTransactionModel> transactions);

  /// Get cached loyalty transaction history
  Future<List<LoyaltyTransactionModel>?> getCachedLoyaltyHistory();

  /// Clear cached loyalty history
  Future<void> clearCachedLoyaltyHistory();

  /// Check if profile data is cached and fresh (not expired)
  Future<bool> isProfileCacheFresh();

  /// Check if loyalty history is cached and fresh (not expired)
  Future<bool> isLoyaltyHistoryCacheFresh();
}
