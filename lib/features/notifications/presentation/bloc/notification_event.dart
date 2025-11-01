import 'package:equatable/equatable.dart';
import 'package:one_atta/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class AddNotification extends NotificationEvent {
  final NotificationEntity notification;

  const AddNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}

class RefreshUnreadCount extends NotificationEvent {
  const RefreshUnreadCount();
}

class UpdateFcmToken extends NotificationEvent {
  final String fcmToken;

  const UpdateFcmToken(this.fcmToken);

  @override
  List<Object?> get props => [fcmToken];
}

class RemoveFcmToken extends NotificationEvent {
  const RemoveFcmToken();
}
