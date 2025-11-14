import 'package:one_atta/core/services/fcm_service.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'dart:developer' as developer;

class NotificationService {
  final FCMService fcmService;
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  NotificationService({
    required this.fcmService,
    required this.notificationRemoteDataSource,
    required this.authLocalDataSource,
  });

  /// Register FCM token with the backend when user logs in
  Future<void> registerFcmToken() async {
    try {
      final fcmToken = fcmService.fcmToken;
      final token = await authLocalDataSource.getToken();
      if (fcmToken != null && token != null) {
        await notificationRemoteDataSource.updateFcmToken(
          token: token,
          fcmToken: fcmToken,
        );
        developer.log('FCM token registered successfully');
      }
    } catch (e) {
      developer.log(
        'Failed to register FCM token',
        name: 'notification_service',
        error: e,
      );
    }
  }

  /// Remove FCM token from backend when user logs out
  Future<void> unregisterFcmToken() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token != null) {
        await notificationRemoteDataSource.removeFcmToken(token: token);
        developer.log('FCM token unregistered successfully');
      }
    } catch (e) {
      developer.log(
        'Failed to unregister FCM token',
        name: 'notification_service',
        error: e,
      );
    }
  }

  /// Subscribe to a notification topic
  Future<void> subscribeToTopic(String topic) async {
    await fcmService.subscribeToTopic(topic);
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await fcmService.unsubscribeFromTopic(topic);
  }
}
