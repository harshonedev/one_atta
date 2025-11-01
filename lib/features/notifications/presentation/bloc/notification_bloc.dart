import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_state.dart';
import 'package:one_atta/core/services/fcm_service.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  final FCMService fcmService;
  final AuthRepository authRepository;
  StreamSubscription? _fcmSubscription;

  NotificationBloc({
    required this.repository,
    required this.fcmService,
    required this.authRepository,
  }) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<AddNotification>(_onAddNotification);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
    on<UpdateFcmToken>(_onUpdateFcmToken);
    on<RemoveFcmToken>(_onRemoveFcmToken);

    // Listen to FCM notification stream
    _fcmSubscription = fcmService.notificationStream.listen((notification) {
      add(AddNotification(notification));
    });
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final notificationsResult = await repository.getNotifications();
    final unreadCountResult = await repository.getUnreadCount();

    notificationsResult.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        unreadCountResult.fold(
          (failure) => emit(NotificationError(failure.message)),
          (unreadCount) => emit(
            NotificationLoaded(
              notifications: notifications,
              unreadCount: unreadCount,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAddNotification(
    AddNotification event,
    Emitter<NotificationState> emit,
  ) async {
    // Save notification to local storage
    await repository.saveNotification(event.notification);

    // Reload notifications
    add(const LoadNotifications());
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.markAsRead(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => add(const LoadNotifications()),
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.markAllAsRead();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => add(const LoadNotifications()),
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.deleteNotification(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => add(const LoadNotifications()),
    );
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.clearAllNotifications();

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      emit(const NotificationLoaded(notifications: [], unreadCount: 0));
    });
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final unreadCountResult = await repository.getUnreadCount();

      unreadCountResult.fold(
        (failure) => emit(NotificationError(failure.message)),
        (unreadCount) => emit(currentState.copyWith(unreadCount: unreadCount)),
      );
    }
  }

  Future<void> _onUpdateFcmToken(
    UpdateFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    final tokenResult = await authRepository.getToken();

    tokenResult.fold((failure) => emit(NotificationError(failure.message)), (
      token,
    ) async {
      if (token == null) {
        emit(const NotificationError('User not authenticated'));
        return;
      }

      final result = await repository.updateFcmToken(token, event.fcmToken);
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (message) => emit(FcmTokenUpdated(message)),
      );
    });
  }

  Future<void> _onRemoveFcmToken(
    RemoveFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    final tokenResult = await authRepository.getToken();

    tokenResult.fold((failure) => emit(NotificationError(failure.message)), (
      token,
    ) async {
      if (token == null) {
        emit(const NotificationError('User not authenticated'));
        return;
      }

      final result = await repository.removeFcmToken(token);
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (message) => emit(FcmTokenRemoved(message)),
      );
    });
  }

  @override
  Future<void> close() {
    _fcmSubscription?.cancel();
    return super.close();
  }
}
