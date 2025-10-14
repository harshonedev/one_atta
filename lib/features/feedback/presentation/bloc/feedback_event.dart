import 'package:equatable/equatable.dart';
import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

class SubmitFeedback extends FeedbackEvent {
  final String subject;
  final String message;
  final String category;
  final String priority;
  final List<FeedbackAttachment>? attachments;

  const SubmitFeedback({
    required this.subject,
    required this.message,
    this.category = 'other',
    this.priority = 'medium',
    this.attachments,
  });

  @override
  List<Object?> get props => [
    subject,
    message,
    category,
    priority,
    attachments,
  ];
}

class LoadFeedbackHistory extends FeedbackEvent {
  final int page;
  final int limit;
  final String? status;

  const LoadFeedbackHistory({this.page = 1, this.limit = 10, this.status});

  @override
  List<Object?> get props => [page, limit, status];
}

class LoadFeedbackById extends FeedbackEvent {
  final String feedbackId;

  const LoadFeedbackById(this.feedbackId);

  @override
  List<Object> get props => [feedbackId];
}
