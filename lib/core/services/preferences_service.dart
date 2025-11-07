import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class PreferencesService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _walkthroughSeenKey = 'walkthrough_seen';

  final SharedPreferences sharedPreferences;

  PreferencesService({required this.sharedPreferences});

  /// Get notification enabled status
  Future<bool> getNotificationsEnabled() async {
    try {
      // Default to true (enabled by default)
      return sharedPreferences.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      developer.log(
        'Error getting notifications enabled status',
        name: 'PreferencesService',
        error: e,
      );
      return true;
    }
  }

  /// Set notification enabled status
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await sharedPreferences.setBool(_notificationsEnabledKey, enabled);
      developer.log(
        'Notifications ${enabled ? 'enabled' : 'disabled'}',
        name: 'PreferencesService',
      );
    } catch (e) {
      developer.log(
        'Error setting notifications enabled status',
        name: 'PreferencesService',
        error: e,
      );
    }
  }

  /// Check if the user has seen the walkthrough
  Future<bool> hasSeenWalkthrough() async {
    try {
      // Default to false (hasn't seen it yet)
      return sharedPreferences.getBool(_walkthroughSeenKey) ?? false;
    } catch (e) {
      developer.log(
        'Error getting walkthrough seen status',
        name: 'PreferencesService',
        error: e,
      );
      return false;
    }
  }

  /// Mark the walkthrough as seen
  Future<void> setWalkthroughSeen() async {
    try {
      await sharedPreferences.setBool(_walkthroughSeenKey, true);
      developer.log('Walkthrough marked as seen', name: 'PreferencesService');
    } catch (e) {
      developer.log(
        'Error setting walkthrough seen status',
        name: 'PreferencesService',
        error: e,
      );
    }
  }
}
