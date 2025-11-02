import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:one_atta/features/reels/data/datasources/reels_local_data_source.dart';
import 'package:one_atta/features/reels/data/models/reel_model.dart';

/// Local data source for caching reel metadata (titles, likes, views, etc.)
///
/// Note: Video caching is handled automatically by Cloudflare Stream CDN
/// with adaptive bitrate and global edge network. This cache only stores
/// reel metadata for offline viewing and faster list loading.
class ReelsLocalDataSourceImpl implements ReelsLocalDataSource {
  static const String _reelsBoxName = 'reels_cache';
  static const String _reelsKey = 'cached_reels';
  static const String _cursorKey = 'cached_cursor';
  static const String _timestampKey = 'cache_timestamp';
  static const int _cacheValidityMinutes =
      30; // Refresh metadata every 30 minutes

  late Box<String> _box;

  static Future<void> initHive() async {
    await Hive.initFlutter();
  }

  Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_reelsBoxName)) {
      _box = await Hive.openBox<String>(_reelsBoxName);
    } else {
      _box = Hive.box<String>(_reelsBoxName);
    }
  }

  @override
  Future<void> cacheReels(List<ReelModel> reels, {String? cursor}) async {
    await _ensureBoxOpen();

    // Convert reels to JSON string for storage
    final reelsJson = reels.map((reel) => reel.toJson()).toList();
    await _box.put(_reelsKey, jsonEncode(reelsJson));

    // Cache cursor if provided
    if (cursor != null) {
      await _box.put(_cursorKey, cursor);
    }

    // Update timestamp
    await updateCacheTimestamp();
  }

  @override
  Future<List<ReelModel>> getCachedReels() async {
    await _ensureBoxOpen();

    final reelsJsonString = _box.get(_reelsKey);
    if (reelsJsonString == null) {
      return [];
    }

    try {
      final reelsJson = jsonDecode(reelsJsonString) as List<dynamic>;
      return reelsJson
          .map((json) => ReelModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, clear cache and return empty list
      await clearCache();
      return [];
    }
  }

  @override
  Future<String?> getCachedCursor() async {
    await _ensureBoxOpen();
    return _box.get(_cursorKey);
  }

  @override
  Future<bool> isCacheValid() async {
    await _ensureBoxOpen();

    final timestampString = _box.get(_timestampKey);
    if (timestampString == null) {
      return false;
    }

    try {
      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference.inMinutes < _cacheValidityMinutes;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    await _ensureBoxOpen();
    await _box.clear();
  }

  @override
  Future<void> updateCacheTimestamp() async {
    await _ensureBoxOpen();
    await _box.put(_timestampKey, DateTime.now().toIso8601String());
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    await _ensureBoxOpen();

    final timestampString = _box.get(_timestampKey);
    if (timestampString == null) {
      return null;
    }

    try {
      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheReel(ReelModel reel) async {
    await _ensureBoxOpen();

    // Get existing reels
    final cachedReels = await getCachedReels();

    // Find and update or add the reel
    final index = cachedReels.indexWhere((r) => r.id == reel.id);
    if (index != -1) {
      cachedReels[index] = reel;
    } else {
      cachedReels.add(reel);
    }

    // Save back to cache
    await cacheReels(cachedReels);
  }

  @override
  Future<ReelModel?> getCachedReel(String reelId) async {
    final cachedReels = await getCachedReels();
    try {
      return cachedReels.firstWhere((reel) => reel.id == reelId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateReelLikeStatus(
    String reelId,
    bool isLiked,
    int likesCount,
  ) async {
    final cachedReels = await getCachedReels();
    final index = cachedReels.indexWhere((reel) => reel.id == reelId);

    if (index != -1) {
      final updatedReel = cachedReels[index].copyWith(
        isLiked: isLiked,
        likes: likesCount,
      );
      cachedReels[index] = updatedReel;
      await cacheReels(cachedReels);
    }
  }

  @override
  Future<void> updateReelViewCount(String reelId, int viewsCount) async {
    final cachedReels = await getCachedReels();
    final index = cachedReels.indexWhere((reel) => reel.id == reelId);

    if (index != -1) {
      final updatedReel = cachedReels[index].copyWith(views: viewsCount);
      cachedReels[index] = updatedReel;
      await cacheReels(cachedReels);
    }
  }
}
