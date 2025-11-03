import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:one_atta/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:one_atta/features/feedback/presentation/bloc/feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository feedbackRepository;

  FeedbackBloc({required this.feedbackRepository}) : super(FeedbackInitial()) {
    on<SubmitFeedback>(_onSubmitFeedback);
    on<LoadFeedbackHistory>(_onLoadFeedbackHistory);
    on<LoadFeedbackById>(_onLoadFeedbackById);
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());

    final result = await feedbackRepository.submitFeedback(
      subject: event.subject,
      message: event.message,
      category: event.category,
      priority: event.priority,
      attachments: event.attachments,
    );

    result.fold(
      (failure) => emit(FeedbackError(failure.message, failure: failure)),
      (feedback) => emit(FeedbackSubmitted(feedback)),
    );
  }

  Future<void> _onLoadFeedbackHistory(
    LoadFeedbackHistory event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());

    final result = await feedbackRepository.getUserFeedbackHistory(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );

    result.fold(
      (failure) => emit(FeedbackError(failure.message, failure: failure)),
      (feedbackList) => emit(FeedbackHistoryLoaded(feedbackList)),
    );
  }

  Future<void> _onLoadFeedbackById(
    LoadFeedbackById event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());

    final result = await feedbackRepository.getFeedbackById(event.feedbackId);

    result.fold(
      (failure) => emit(FeedbackError(failure.message, failure: failure)),
      (feedback) => emit(FeedbackDetailLoaded(feedback)),
    );
  }
}
