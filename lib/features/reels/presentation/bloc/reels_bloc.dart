import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/reels/domain/repositories/reels_repository.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_event.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final ReelsRepository reelsRepository;
  final Logger logger = Logger();

  ReelsBloc({required this.reelsRepository}) : super(const ReelsInitial()) {
    on<LoadReelsFeed>(_onLoadReelsFeed);
    on<LoadMoreReels>(_onLoadMoreReels);
    on<IncrementReelView>(_onIncrementReelView);
    on<ToggleReelLike>(_onToggleReelLike);
    on<ShareReel>(_onShareReel);
    on<ReelLikedStatusRequested>(_onReelLikedStatusRequested);
    on<ClearErrorMessage>(_onClearErrorMessage);
  }

  Future<void> _onLoadReelsFeed(
    LoadReelsFeed event,
    Emitter<ReelsState> emit,
  ) async {
    if (event.refresh || state is! ReelsFeedLoaded) {
      emit(const ReelsLoading());
    }

    logger.i('Loading reels feed${event.refresh ? ' (refresh)' : ''}');

    final result = await reelsRepository.getReelsFeed(limit: 20);

    result.fold(
      (failure) {
        logger.e('Failed to load reels feed: ${failure.message}');
        emit(ReelsError(message: failure.message));
      },
      (feedData) {
        logger.i('Loaded ${feedData.reels.length} reels');
        emit(
          ReelsFeedLoaded(
            reels: feedData.reels,
            nextCursor: feedData.nextCursor,
            hasMore: feedData.hasMore,
          ),
        );
      },
    );
  }

  void _onClearErrorMessage(ClearErrorMessage event, Emitter<ReelsState> emit) {
    if (state is ReelsFeedLoaded) {
      final currentState = state as ReelsFeedLoaded;
      emit(currentState.copyWith(errorMessage: null));
    }
  }

  Future<void> _onLoadMoreReels(
    LoadMoreReels event,
    Emitter<ReelsState> emit,
  ) async {
    if (state is ReelsFeedLoaded) {
      final currentState = state as ReelsFeedLoaded;

      if (!currentState.hasMore || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      logger.i('Loading more reels with cursor: ${currentState.nextCursor}');

      final result = await reelsRepository.getReelsFeed(
        limit: 20,
        cursor: currentState.nextCursor,
      );

      result.fold(
        (failure) {
          logger.e('Failed to load more reels: ${failure.message}');
          emit(currentState.copyWith(isLoadingMore: false));
          emit(ReelsError(message: failure.message));
        },
        (feedData) {
          logger.i('Loaded ${feedData.reels.length} more reels');
          final updatedReels = [...currentState.reels, ...feedData.reels];
          emit(
            ReelsFeedLoaded(
              reels: updatedReels,
              nextCursor: feedData.nextCursor,
              hasMore: feedData.hasMore,
            ),
          );
        },
      );
    }
  }

  Future<void> _onIncrementReelView(
    IncrementReelView event,
    Emitter<ReelsState> emit,
  ) async {
    logger.i('Incrementing view count for reel: ${event.reelId}');

    final result = await reelsRepository.incrementViewCount(event.reelId);

    result.fold(
      (failure) {
        logger.e('Failed to increment view count: ${failure.message}');
        // Don't emit error state for view count failures as it's not critical
      },
      (newViewCount) {
        logger.i('View count updated to: $newViewCount');
        // Optionally emit a specific state if needed for UI updates
        final currentState = state;
        if (currentState is ReelsFeedLoaded) {
          final updatedReels = currentState.reels.map((reel) {
            if (reel.id == event.reelId) {
              return reel.copyWith(views: newViewCount);
            }
            return reel;
          }).toList();
          emit(currentState.copyWith(reels: updatedReels));
        }
      },
    );
  }

  Future<void> _onToggleReelLike(
    ToggleReelLike event,
    Emitter<ReelsState> emit,
  ) async {
    logger.i('Toggling like for reel: ${event.reelId}');

    if (state is! ReelsFeedLoaded) {
      logger.w('Cannot toggle like, reels feed not loaded');
      return;
    }

    final currentState = state as ReelsFeedLoaded;

    final updatedList = currentState.reels.map((r) {
      if (r.id == event.reelId) {
        if (r.isLiked) {
          return r.copyWith(isLiked: false, likes: r.likes - 1);
        } else {
          return r.copyWith(isLiked: true, likes: r.likes + 1);
        }
      }
      return r;
    }).toList();
    emit(currentState.copyWith(reels: updatedList));
    final result = await reelsRepository.toggleReelLike(event.reelId);

    result.fold(
      (failure) {
        logger.e('Failed to toggle reel like: ${failure.message}');
      },
      (likeData) {
        logger.i(
          'Toggled like for reel: ${event.reelId}, isLiked: ${likeData.isLiked}',
        );
        final updatedList = currentState.reels.map((r) {
          if (r.id == event.reelId) {
            return r.copyWith(
              isLiked: likeData.isLiked,
              likes: likeData.likesCount,
            );
          }
          return r;
        }).toList();

        emit(currentState.copyWith(reels: updatedList));
      },
    );
  }

  Future<void> _onReelLikedStatusRequested(
    ReelLikedStatusRequested event,
    Emitter<ReelsState> emit,
  ) async {
    logger.i('Toggling like for reel: ${event.reelId}');

    if (state is! ReelsFeedLoaded) {
      logger.w('Cannot requested  liked status, reels feed not loaded');
      return;
    }

    final currentState = state as ReelsFeedLoaded;

    final result = await reelsRepository.getReelLikedStatus(event.reelId);

    result.fold(
      (failure) {
        logger.e('Failed to requested  liked status: ${failure.message}');
      },
      (likeData) {
        logger.i(
          'Get like status for reel: ${event.reelId}, isLiked: ${likeData.isLiked}',
        );
        final updatedList = currentState.reels.map((r) {
          if (r.id == event.reelId) {
            return r.copyWith(
              isLiked: likeData.isLiked,
              likes: likeData.likesCount,
            );
          }
          return r;
        }).toList();

        emit(currentState.copyWith(reels: updatedList));
      },
    );
  }

  Future<void> _onShareReel(ShareReel event, Emitter<ReelsState> emit) async {
    logger.i('Sharing reel: ${event.reelId} with type: ${event.shareType}');

    if (state is! ReelsFeedLoaded) {
      logger.w('Cannot share reel, reels feed not loaded');
      return;
    }

    final currentState = state as ReelsFeedLoaded;

    final result = await reelsRepository.shareReel(
      event.reelId,
      shareType: event.shareType,
    );

    result.fold(
      (failure) {
        logger.e('Failed to share reel: ${failure.message}');
      },
      (shareData) {
        logger.i(
          'Shared reel: ${event.reelId}, shareUrl: ${shareData.shareUrl}',
        );
        final updatedReels = currentState.reels.map((reel) {
          if (reel.id == shareData.reelId) {
            return reel.copyWith(shares: shareData.sharesCount);
          }
          return reel;
        }).toList();
        emit(currentState.copyWith(reels: updatedReels));
      },
    );
  }
}
