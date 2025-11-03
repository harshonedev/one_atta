import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  final Failure? failure;

  const NotificationError(this.message, {this.failure});

  @override
  List<Object?> get props => [message, failure];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FcmTokenUpdated extends NotificationState {
  final String message;

  const FcmTokenUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class FcmTokenRemoved extends NotificationState {
  final String message;

  const FcmTokenRemoved(this.message);

  @override
  List<Object?> get props => [message];
}
