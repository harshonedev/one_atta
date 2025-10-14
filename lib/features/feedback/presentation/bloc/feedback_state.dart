import 'package:equatable/equatable.dart';
import 'package:one_atta/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSubmitted extends FeedbackState {
  final FeedbackEntity feedback;

  const FeedbackSubmitted(this.feedback);

  @override
  List<Object> get props => [feedback];
}

class FeedbackHistoryLoaded extends FeedbackState {
  final List<FeedbackEntity> feedbackList;

  const FeedbackHistoryLoaded(this.feedbackList);

  @override
  List<Object> get props => [feedbackList];
}

class FeedbackDetailLoaded extends FeedbackState {
  final FeedbackEntity feedback;

  const FeedbackDetailLoaded(this.feedback);

  @override
  List<Object> get props => [feedback];
}

class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object> get props => [message];
}
