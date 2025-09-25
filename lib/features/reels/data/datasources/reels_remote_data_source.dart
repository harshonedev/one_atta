import 'package:one_atta/features/reels/data/models/reel_model.dart';

abstract class ReelsRemoteDataSource {
  /// Get reels feed with pagination
  Future<ReelsFeedModel> getReelsFeed({int? limit, String? cursor});

  /// Increment view count for a reel
  Future<int> incrementViewCount(String token, String id);

  /// Toggle like on a reel
  Future<ReelLikeResponse> toggleReelLike(String token, String reelId);

  // Reel Liked Status
  Future<ReelLikeResponse> getReelLikedStatus(String token, String reelId);

  /// Share a reel
  Future<ReelShareResponse> shareReel(
    String token,
    String reelId, {
    String shareType = 'link',
  });
}
