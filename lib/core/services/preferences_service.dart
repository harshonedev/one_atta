import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class PreferencesService {
  static const String _notificationsEnabledKey = 'notifications_enabled';

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
}
