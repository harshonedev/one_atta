import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:one_atta/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:one_atta/features/notifications/domain/entities/notification_entity.dart';
import 'package:one_atta/features/notifications/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> saveNotification(
    NotificationEntity notification,
  );
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, void>> clearAllNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, String>> updateFcmToken(String token, String fcmToken);
  Future<Either<Failure, String>> removeFcmToken(String token);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await localDataSource.getNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await localDataSource.saveNotification(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await localDataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await localDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await localDataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    try {
      await localDataSource.clearAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await localDataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateFcmToken(
    String token,
    String fcmToken,
  ) async {
    try {
      final response = await remoteDataSource.updateFcmToken(
        token: token,
        fcmToken: fcmToken,
      );
      return Right(response.message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> removeFcmToken(String token) async {
    try {
      final response = await remoteDataSource.removeFcmToken(token: token);
      return Right(response.message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
