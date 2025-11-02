import 'package:one_atta/features/reels/data/models/reel_model.dart';

abstract class ReelsRemoteDataSource {
  /// Get reels feed with cursor-based pagination
  Future<ReelsFeedModel> getReelsFeed({int? limit, String? cursor});

  /// Get detailed information about a specific reel
  Future<ReelDetailModel> getReelDetails(String id);

  /// Increment view count for a reel (public endpoint)
  Future<int> incrementViewCount(String id);

  /// Get reels by blend
  Future<List<ReelModel>> getReelsByBlend(String blendId, {int? limit});

  /// Search reels by caption or tags
  Future<ReelSearchResultModel> searchReels(String query, {int? limit});

  /// Toggle like on a reel (authenticated)
  Future<ReelLikeResponse> toggleReelLike(String token, String reelId);

  /// Get reel liked status (authenticated)
  Future<ReelLikeResponse> getReelLikedStatus(String token, String reelId);

  /// Share a reel (authenticated)
  Future<ReelShareResponse> shareReel(
    String token,
    String reelId, {
    String shareType = 'link',
  });
}
