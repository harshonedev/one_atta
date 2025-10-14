import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';
import 'package:one_atta/features/feedback/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  FeedbackRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<String?> _getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<Either<Failure, FeedbackEntity>> submitFeedback({
    required String subject,
    required String message,
    String category = 'other',
    String priority = 'medium',
    List<FeedbackAttachment>? attachments,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return const Left(UnauthorizedFailure('No authentication token found'));
      }

      final result = await remoteDataSource.submitFeedback(
        subject: subject,
        message: message,
        token: token,
        category: category,
        priority: priority,
        attachments: attachments,
      );
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to submit feedback: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FeedbackEntity>>> getUserFeedbackHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return const Left(UnauthorizedFailure('No authentication token found'));
      }

      final result = await remoteDataSource.getUserFeedbackHistory(
        token: token,
        page: page,
        limit: limit,
        status: status,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch feedback history: $e'));
    }
  }

  @override
  Future<Either<Failure, FeedbackEntity>> getFeedbackById(
    String feedbackId,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return const Left(UnauthorizedFailure('No authentication token found'));
      }

      final result = await remoteDataSource.getFeedbackById(
        feedbackId: feedbackId,
        token: token,
      );
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch feedback: $e'));
    }
  }
}
