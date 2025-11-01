# Firebase Cloud Messaging (FCM) Notifications

## Overview

This document explains how to use the FCM notification system implemented in the One Atta app.

## Features

- **Push Notifications**: Receive notifications when app is in foreground, background, or terminated
- **Local Storage**: Notifications are saved locally for history viewing
- **Notification Management**: Mark as read, delete, or clear all notifications
- **Unread Badge**: Display unread notification count in the app
- **Deep Linking**: Navigate to specific screens based on notification type
- **Topic Subscriptions**: Subscribe to notification topics for targeted messaging

## Architecture

The notification system follows clean architecture principles:

```
lib/features/notifications/
├── data/
│   ├── datasources/
│   │   └── notification_local_data_source.dart
│   ├── models/
│   │   └── notification_model.dart
│   └── repositories/
│       └── notification_repository_impl.dart
├── domain/
│   └── entities/
│       └── notification_entity.dart
└── presentation/
    ├── bloc/
    │   ├── notification_bloc.dart
    │   ├── notification_event.dart
    │   └── notification_state.dart
    ├── pages/
    │   └── notifications_page.dart
    └── widgets/
        └── notification_badge_icon.dart

lib/core/services/
└── fcm_service.dart
```

## Setup

### 1. Firebase Project Setup

1. Ensure Firebase is configured in your project
2. Add your Android app to Firebase Console
3. Download and place `google-services.json` in `android/app/`
4. Enable Cloud Messaging in Firebase Console

### 2. Required Packages

Already added to `pubspec.yaml`:
- `firebase_messaging: ^16.0.3`
- `flutter_local_notifications: ^19.5.0`

### 3. Android Configuration

The following permissions and configurations are already set in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

## Usage

### Sending Notifications

#### From Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Select target (specific device token or topic)
5. Add optional data payload:
   ```json
   {
     "type": "order",
     "orderId": "12345"
   }
   ```

#### From Backend Server

Send POST request to FCM API:

```bash
POST https://fcm.googleapis.com/fcm/send
Content-Type: application/json
Authorization: key=YOUR_SERVER_KEY

{
  "to": "DEVICE_FCM_TOKEN",
  "notification": {
    "title": "Order Delivered!",
    "body": "Your order #12345 has been delivered"
  },
  "data": {
    "type": "order",
    "orderId": "12345"
  }
}
```

### Notification Types

The app supports different notification types with custom icons:

- `order` - Green shopping bag icon
- `promotion` - Orange offer icon
- `delivery` - Blue shipping icon
- `general` - Primary color bell icon (default)

Example payload:

```json
{
  "notification": {
    "title": "New Order",
    "body": "Your order has been confirmed"
  },
  "data": {
    "type": "order",
    "orderId": "12345",
    "status": "confirmed"
  }
}
```

### Handling Notification Taps

Update the `_handleNotificationTap` method in `notifications_page.dart`:

```dart
void _handleNotificationTap(
  BuildContext context,
  NotificationEntity notification,
) {
  // Navigate based on notification type
  if (notification.type == 'order' && notification.data?['orderId'] != null) {
    context.push('/orders/${notification.data!['orderId']}');
  } else if (notification.type == 'promotion') {
    context.push('/offers');
  }
  // Add more cases as needed
}
```

### Topic Subscriptions

Subscribe users to topics for targeted notifications:

```dart
// Get FCM service
final fcmService = sl<FCMService>();

// Subscribe to topic
await fcmService.subscribeToTopic('all_users');
await fcmService.subscribeToTopic('premium_users');

// Unsubscribe from topic
await fcmService.unsubscribeFromTopic('premium_users');
```

### Displaying Notification Badge

The `NotificationBadgeIcon` widget is already integrated in the home page header. To add it elsewhere:

```dart
import 'package:one_atta/features/notifications/presentation/widgets/notification_badge_icon.dart';

// In your AppBar
AppBar(
  title: Text('My Page'),
  actions: [
    NotificationBadgeIcon(),
  ],
)
```

### Accessing Notifications Programmatically

```dart
// Get notification bloc
final notificationBloc = context.read<NotificationBloc>();

// Load notifications
notificationBloc.add(const LoadNotifications());

// Mark notification as read
notificationBloc.add(MarkNotificationAsRead('notification_id'));

// Mark all as read
notificationBloc.add(const MarkAllNotificationsAsRead());

// Delete notification
notificationBloc.add(DeleteNotification('notification_id'));

// Clear all
notificationBloc.add(const ClearAllNotifications());
```

## Testing

### Test Foreground Notifications

1. Open the app
2. Send a test notification from Firebase Console
3. Notification should appear at the top of the screen
4. It should also be saved in the notifications page

### Test Background Notifications

1. Minimize the app (don't close it)
2. Send a test notification
3. Notification should appear in system tray
4. Tap notification to open app
5. Notification should be in the notifications page

### Test Terminated State

1. Completely close the app
2. Send a test notification
3. Tap the notification
4. App should open and notification should be in the list

### Get FCM Token

To get the device FCM token for testing:

```dart
// Add this temporarily to see the token
final fcmService = sl<FCMService>();
print('FCM Token: ${fcmService.fcmToken}');
```

Or check the logs when the app starts:
```
[FCMService] FCM Token: <your-token-here>
```

## Notification Data Structure

```dart
class NotificationEntity {
  final String id;              // Unique identifier
  final String title;           // Notification title
  final String body;            // Notification body/message
  final String? imageUrl;       // Optional image URL
  final Map<String, dynamic>? data; // Custom data payload
  final DateTime timestamp;     // When notification was received
  final bool isRead;           // Read status
  final String? type;          // Notification type
}
```

## Best Practices

1. **Always include a type**: Add a `type` field in the data payload for proper icon and navigation handling
2. **Keep data small**: FCM has a 4KB limit for data payloads
3. **Use topics wisely**: Group users by topics (e.g., 'premium', 'orders', 'promotions')
4. **Test all states**: Test notifications in foreground, background, and terminated states
5. **Handle navigation**: Always check if the app context is valid before navigation
6. **Localization**: Send notifications in the user's preferred language

## Troubleshooting

### Notifications not appearing

1. Check if notification permission is granted (Android 13+)
2. Verify FCM token is being generated
3. Check Firebase Console for any errors
4. Ensure `google-services.json` is up to date

### Badge not updating

The badge updates automatically via BLoC state. If not working:
1. Ensure NotificationBloc is provided in main.dart
2. Check if LoadNotifications event is being triggered
3. Verify SharedPreferences is working

### Deep linking not working

1. Implement the `_handleNotificationTap` method properly
2. Ensure routes are defined in `app_router.dart`
3. Check if notification data contains required fields

## Future Enhancements

- [ ] Rich notifications with images
- [ ] Action buttons on notifications
- [ ] Notification categories/channels
- [ ] Scheduled local notifications
- [ ] Notification sound customization
- [ ] Notification priority levels
- [ ] Analytics for notification opens/engagement
