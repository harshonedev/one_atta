import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackRepository {
  // Submit new feedback
  Future<Either<Failure, FeedbackEntity>> submitFeedback({
    required String subject,
    required String message,
    String category = 'other',
    String priority = 'medium',
    List<FeedbackAttachment>? attachments,
  });

  // Get user's feedback history
  Future<Either<Failure, List<FeedbackEntity>>> getUserFeedbackHistory({
    int page = 1,
    int limit = 10,
    String? status,
  });

  // Get specific feedback by ID
  Future<Either<Failure, FeedbackEntity>> getFeedbackById(String feedbackId);
}
