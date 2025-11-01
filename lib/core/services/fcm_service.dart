import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:one_atta/features/notifications/domain/entities/notification_entity.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Handling background message: ${message.messageId}',
    name: 'FCMService',
  );
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationEntity> _notificationController =
      StreamController<NotificationEntity>.broadcast();

  Stream<NotificationEntity> get notificationStream =>
      _notificationController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Callback for when FCM token changes
  Function(String)? onTokenUpdated;

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      developer.log(
        'Notification permission status: ${settings.authorizationStatus}',
        name: 'FCMService',
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        developer.log(
          'Notification permission denied',
          name: 'FCMService',
          level: 900,
        );
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getToken();

      // Set up message handlers
      _setupMessageHandlers();

      // Handle notification tap when app is terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e, s) {
      developer.log(
        'Error initializing FCM',
        name: 'FCMService',
        level: 1000,
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      developer.log('FCM Token: $_fcmToken', name: 'FCMService');
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        developer.log('FCM Token refreshed: $newToken', name: 'FCMService');
        // Notify about token update
        onTokenUpdated?.call(newToken);
      });
    } catch (e) {
      developer.log(
        'Error getting FCM token',
        name: 'FCMService',
        level: 1000,
        error: e,
      );
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'Foreground message received: ${message.notification?.title}',
        name: 'FCMService',
      );

      final notification = _createNotificationEntity(message);
      _notificationController.add(notification);

      // Show local notification
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    developer.log('Notification tapped: ${message.data}', name: 'FCMService');

    final notification = _createNotificationEntity(message);
    _notificationController.add(notification);

    // TODO: Handle navigation based on notification type
    // Example: Navigate to order details if type is 'order'
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'Local notification tapped: ${response.payload}',
      name: 'FCMService',
    );
  }

  /// Create notification entity from remote message
  NotificationEntity _createNotificationEntity(RemoteMessage message) {
    return NotificationEntity(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      imageUrl:
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
      timestamp: message.sentTime ?? DateTime.now(),
      isRead: false,
      type: message.data['type'] as String?,
    );
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic', name: 'FCMService');
    } catch (e) {
      developer.log(
        'Error subscribing to topic',
        name: 'FCMService',
        level: 1000,
        error: e,
      );
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic', name: 'FCMService');
    } catch (e) {
      developer.log(
        'Error unsubscribing from topic',
        name: 'FCMService',
        level: 1000,
        error: e,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
  }
}
