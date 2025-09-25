import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';

abstract class ReelsRepository {
  /// Get reels feed with pagination
  Future<Either<Failure, ReelsFeedEntity>> getReelsFeed({
    int? limit,
    String? cursor,
  });

  /// Increment view count for a reel
  Future<Either<Failure, int>> incrementViewCount(String id);

  /// Toggle like on a reel
  Future<Either<Failure, ReelLikeEntity>> toggleReelLike(String reelId);

  // Get Reel Liked Status
  Future<Either<Failure, ReelLikeEntity>> getReelLikedStatus(String reelId);

  /// Share a reel
  Future<Either<Failure, ReelShareEntity>> shareReel(
    String reelId, {
    String shareType = 'link',
  });
}
