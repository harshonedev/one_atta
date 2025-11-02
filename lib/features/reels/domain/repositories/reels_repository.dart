import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';

abstract class ReelsRepository {
  /// Get reels feed with cursor-based pagination
  Future<Either<Failure, ReelsFeedEntity>> getReelsFeed({
    int? limit,
    String? cursor,
    bool forceRefresh = false,
  });

  /// Get detailed information about a specific reel
  Future<Either<Failure, ReelDetailEntity>> getReelDetails(String id);

  /// Increment view count for a reel (public endpoint)
  Future<Either<Failure, int>> incrementViewCount(String id);

  /// Get reels by blend
  Future<Either<Failure, List<ReelEntity>>> getReelsByBlend(
    String blendId, {
    int? limit,
  });

  /// Search reels by caption or tags
  Future<Either<Failure, ReelSearchResultEntity>> searchReels(
    String query, {
    int? limit,
  });

  /// Toggle like on a reel (authenticated)
  Future<Either<Failure, ReelLikeEntity>> toggleReelLike(String reelId);

  /// Get reel liked status (authenticated)
  Future<Either<Failure, ReelLikeEntity>> getReelLikedStatus(String reelId);

  /// Share a reel (authenticated)
  Future<Either<Failure, ReelShareEntity>> shareReel(
    String reelId, {
    String shareType = 'link',
  });
}
