import 'package:one_atta/features/feedback/data/models/feedback_model.dart';
import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackRemoteDataSource {
  Future<FeedbackModel> submitFeedback({
    required String subject,
    required String message,
    required String token,
    String category = 'other',
    String priority = 'medium',
    List<FeedbackAttachment>? attachments,
  });

  Future<List<FeedbackModel>> getUserFeedbackHistory({
    required String token,
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<FeedbackModel> getFeedbackById({
    required String feedbackId,
    required String token,
  });
}
