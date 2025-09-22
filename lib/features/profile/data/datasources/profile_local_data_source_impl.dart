import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String userProfileKey = 'user_profile_cache';
  static const String loyaltyHistoryKey = 'loyalty_history_cache';
  static const String profileCacheTimeKey = 'profile_cache_time';
  static const String loyaltyHistoryCacheTimeKey = 'loyalty_history_cache_time';

  // Cache expiration times (in milliseconds)
  static const int profileCacheExpiration = 15 * 60 * 1000; // 15 minutes
  static const int loyaltyCacheExpiration = 30 * 60 * 1000; // 30 minutes

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    try {
      final profileJson = json.encode(profile.toJson());
      await sharedPreferences.setString(userProfileKey, profileJson);
      await sharedPreferences.setInt(
        profileCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheFailure('Failed to cache user profile: $e');
    }
  }

  @override
  Future<UserProfileModel?> getCachedUserProfile() async {
    try {
      final profileJson = sharedPreferences.getString(userProfileKey);
      if (profileJson != null) {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      }
      return null;
    } catch (e) {
      throw CacheFailure('Failed to get cached user profile: $e');
    }
  }

  @override
  Future<void> clearCachedProfile() async {
    try {
      await sharedPreferences.remove(userProfileKey);
      await sharedPreferences.remove(profileCacheTimeKey);
    } catch (e) {
      throw CacheFailure('Failed to clear cached profile: $e');
    }
  }

  @override
  Future<void> cacheLoyaltyHistory(
    List<LoyaltyTransactionModel> transactions,
  ) async {
    try {
      final transactionsJson = json.encode(
        transactions.map((transaction) => transaction.toJson()).toList(),
      );
      await sharedPreferences.setString(loyaltyHistoryKey, transactionsJson);
      await sharedPreferences.setInt(
        loyaltyHistoryCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheFailure('Failed to cache loyalty history: $e');
    }
  }

  @override
  Future<List<LoyaltyTransactionModel>?> getCachedLoyaltyHistory() async {
    try {
      final historyJson = sharedPreferences.getString(loyaltyHistoryKey);
      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List<dynamic>;
        return historyList
            .map((transaction) => LoyaltyTransactionModel.fromJson(transaction))
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheFailure('Failed to get cached loyalty history: $e');
    }
  }

  @override
  Future<void> clearCachedLoyaltyHistory() async {
    try {
      await sharedPreferences.remove(loyaltyHistoryKey);
      await sharedPreferences.remove(loyaltyHistoryCacheTimeKey);
    } catch (e) {
      throw CacheFailure('Failed to clear cached loyalty history: $e');
    }
  }

  @override
  Future<bool> isProfileCacheFresh() async {
    try {
      final cacheTime = sharedPreferences.getInt(profileCacheTimeKey);
      if (cacheTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - cacheTime) < profileCacheExpiration;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLoyaltyHistoryCacheFresh() async {
    try {
      final cacheTime = sharedPreferences.getInt(loyaltyHistoryCacheTimeKey);
      if (cacheTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - cacheTime) < loyaltyCacheExpiration;
    } catch (e) {
      return false;
    }
  }
}
