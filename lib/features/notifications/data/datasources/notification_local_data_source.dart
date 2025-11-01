import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:one_atta/features/notifications/data/models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> saveNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAllNotifications();
  Future<int> getUnreadCount();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _notificationsKey = 'saved_notifications';
  final SharedPreferences sharedPreferences;

  NotificationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final jsonString = sharedPreferences.getString(_notificationsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final notifications = await getNotifications();

      // Avoid duplicates
      final existingIndex = notifications.indexWhere(
        (n) => n.id == notification.id,
      );
      if (existingIndex != -1) {
        notifications[existingIndex] = notification;
      } else {
        notifications.insert(0, notification);
      }

      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }

      final jsonString = jsonEncode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await sharedPreferences.setString(_notificationsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        final jsonString = jsonEncode(
          notifications.map((n) => n.toJson()).toList(),
        );
        await sharedPreferences.setString(_notificationsKey, jsonString);
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      final jsonString = jsonEncode(
        updatedNotifications.map((n) => n.toJson()).toList(),
      );
      await sharedPreferences.setString(_notificationsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      final jsonString = jsonEncode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await sharedPreferences.setString(_notificationsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await sharedPreferences.remove(_notificationsKey);
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }
}
