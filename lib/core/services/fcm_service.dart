import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:one_atta/features/notifications/domain/entities/notification_entity.dart';
import 'package:one_atta/core/services/preferences_service.dart';
import 'package:one_atta/core/routing/app_router.dart';

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

  // Preferences service for checking notification settings
  PreferencesService? _preferencesService;

  void setPreferencesService(PreferencesService service) {
    _preferencesService = service;
  }

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
    // Check if notifications are enabled
    if (_preferencesService != null) {
      final notificationsEnabled = await _preferencesService!
          .getNotificationsEnabled();
      if (!notificationsEnabled) {
        developer.log(
          'Notifications are disabled by user, skipping local notification',
          name: 'FCMService',
        );
        return;
      }
    }

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      // Create a structured payload for navigation
      final payload = _createNavigationPayload(message.data);

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
        payload: payload,
      );
    }
  }

  /// Create navigation payload from notification data
  String _createNavigationPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return 'notifications';

    final action = data['action'] as String?;
    if (action == null) return 'notifications';

    switch (action.toLowerCase()) {
      case 'order':
      case 'order_update':
      case 'order_delivered':
      case 'order_cancelled':
        final orderId = data['order_id'] as String?;
        return orderId != null ? 'order:$orderId' : 'orders';

      case 'recipe':
      case 'new_recipe':
        final recipeId = data['recipe_id'] as String?;
        return recipeId != null ? 'recipe:$recipeId' : 'recipes';

      case 'blend':
      case 'custom_blend':
        final blendId = data['blend_id'] as String?;
        return blendId != null ? 'blend:$blendId' : 'blends';

      case 'product':
      case 'daily_essential':
        final productId = data['product_id'] as String?;
        return productId != null
            ? 'product:$productId'
            : 'daily-essentials-list';

      case 'loyalty':
      case 'reward':
        return 'rewards';

      case 'cart':
        return 'cart';

      case 'profile':
        return 'profile';

      case 'general':
      case 'announcement':
      case 'promotional':
      default:
        return 'notifications';
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    developer.log('Notification tapped: ${message.data}', name: 'FCMService');

    final notification = _createNotificationEntity(message);
    _notificationController.add(notification);

    // Handle navigation based on notification type
    _navigateFromNotification(message.data);
  }

  /// Navigate to appropriate screen based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    if (data.isEmpty) {
      AppRouter.router.push('/notifications');
      return;
    }

    final action = data['action'] as String?;

    if (action == null) {
      AppRouter.router.push('/notifications');
      return;
    }

    switch (action.toLowerCase()) {
      case 'view_order':
        final orderId = data['orderId'] as String?;
        if (orderId != null) {
          AppRouter.router.push('/order-details/$orderId');
        } else {
          AppRouter.router.push('/orders');
        }
        break;

      case 'loyalty_points_earned':
      case 'blend_share_points_earned':
        AppRouter.router.push('/rewards');
        break;

      case 'view_expiring_items':
        AppRouter.router.push('/expiring-items');
        break;

      default:
        AppRouter.router.push('/notifications');
        break;
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'Local notification tapped: ${response.payload}',
      name: 'FCMService',
    );

    // Parse the payload and navigate accordingly
    if (response.payload != null && response.payload!.isNotEmpty) {
      _navigateFromPayload(response.payload!);
    } else {
      AppRouter.router.push('/notifications');
    }
  }

  /// Navigate based on structured payload
  void _navigateFromPayload(String payload) {
    try {
      if (payload.contains(':')) {
        final parts = payload.split(':');
        final type = parts[0];
        final id = parts.length > 1 ? parts[1] : null;

        switch (type) {
          case 'order':
            if (id != null) {
              AppRouter.router.push('/order-details/$id');
            } else {
              AppRouter.router.push('/orders');
            }
            break;
          case 'recipe':
            if (id != null) {
              AppRouter.router.push('/recipe-details/$id');
            } else {
              AppRouter.router.push('/recipes');
            }
            break;
          case 'blend':
            if (id != null) {
              AppRouter.router.push('/blend-details/$id');
            } else {
              AppRouter.router.push('/blends');
            }
            break;
          case 'product':
            if (id != null) {
              AppRouter.router.push('/daily-essential-details/$id');
            } else {
              AppRouter.router.push('/daily-essentials-list');
            }
            break;
          default:
            AppRouter.router.push('/notifications');
            break;
        }
      } else {
        // Handle direct routes
        switch (payload) {
          case 'orders':
            AppRouter.router.push('/orders');
            break;
          case 'recipes':
            AppRouter.router.push('/recipes');
            break;
          case 'blends':
            AppRouter.router.push('/blends');
            break;
          case 'daily-essentials-list':
            AppRouter.router.push('/daily-essentials-list');
            break;
          case 'rewards':
            AppRouter.router.push('/rewards');
            break;
          case 'cart':
            AppRouter.router.push('/cart');
            break;
          case 'profile':
            AppRouter.router.push('/profile');
            break;
          case 'notifications':
          default:
            AppRouter.router.push('/notifications');
            break;
        }
      }
    } catch (e) {
      developer.log(
        'Error parsing notification payload',
        name: 'FCMService',
        level: 900,
        error: e,
      );
      // Fallback navigation
      AppRouter.router.push('/notifications');
    }
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

  /// Programmatically navigate from notification data (can be called from other services)
  void navigateFromNotificationData(Map<String, dynamic> data) {
    developer.log(
      'Programmatic navigation from notification data: $data',
      name: 'FCMService',
    );
    _navigateFromNotification(data);
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
  }
}
