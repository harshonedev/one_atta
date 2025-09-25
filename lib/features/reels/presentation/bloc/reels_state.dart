import 'package:equatable/equatable.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

class ReelsInitial extends ReelsState {
  const ReelsInitial();
}

class ReelsLoading extends ReelsState {
  const ReelsLoading();
}

class ReelsFeedLoaded extends ReelsState {
  final List<ReelEntity> reels;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const ReelsFeedLoaded({
    required this.reels,
    this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [reels, nextCursor, hasMore, isLoadingMore, errorMessage];

  ReelsFeedLoaded copyWith({
    List<ReelEntity>? reels,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return ReelsFeedLoaded(
      reels: reels ?? this.reels,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }
}

class ReelsError extends ReelsState {
  final String message;

  const ReelsError({required this.message});

  @override
  List<Object?> get props => [message];
}


