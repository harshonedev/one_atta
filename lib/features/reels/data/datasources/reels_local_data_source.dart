import 'package:one_atta/features/reels/data/models/reel_model.dart';

abstract class ReelsLocalDataSource {
  /// Cache reels data with timestamp
  Future<void> cacheReels(List<ReelModel> reels, {String? cursor});

  /// Get cached reels
  Future<List<ReelModel>> getCachedReels();

  /// Get cached cursor for pagination
  Future<String?> getCachedCursor();

  /// Check if cache is valid (within 30 minutes for URL expiry)
  Future<bool> isCacheValid();

  /// Clear all cached reels
  Future<void> clearCache();

  /// Update cache timestamp to current time
  Future<void> updateCacheTimestamp();

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp();

  /// Cache individual reel
  Future<void> cacheReel(ReelModel reel);

  /// Get cached reel by ID
  Future<ReelModel?> getCachedReel(String reelId);

  /// Update reel like status in cache
  Future<void> updateReelLikeStatus(
    String reelId,
    bool isLiked,
    int likesCount,
  );

  /// Update reel view count in cache
  Future<void> updateReelViewCount(String reelId, int viewsCount);
}
