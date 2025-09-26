import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoCacheManager {
  static const String _keyPrefix = 'reel_video_';
  static const Duration _cacheValidDuration = Duration(
    hours: 1,
  ); // Match URL expiry
  static VideoCacheManager? _instance;
  final Logger _logger = Logger();

  static VideoCacheManager get instance {
    _instance ??= VideoCacheManager._();
    return _instance!;
  }

  VideoCacheManager._();

  late final CacheManager _cacheManager;

  Future<void> init() async {
    final directory = await getTemporaryDirectory();
    final cacheDir = path.join(directory.path, 'reel_videos');

    _cacheManager = CacheManager(
      Config(
        'reel_video_cache',
        stalePeriod: _cacheValidDuration,
        maxNrOfCacheObjects: 50, // Limit number of cached videos
        repo: JsonCacheInfoRepository(databaseName: 'reel_video_cache'),
        fileService: HttpFileService(),
        fileSystem: IOFileSystem(cacheDir),
      ),
    );
  }

  /// Pre-cache video for better loading performance
  Future<void> preCache(String videoUrl, String reelId) async {
    try {
      final key = _keyPrefix + reelId;
      await _cacheManager.downloadFile(videoUrl, key: key);
    } catch (e) {
      // Silently handle cache failures - video will load from network
      _logger.w('Failed to pre-cache video for reel $reelId: $e');
    }
  }

  /// Get cached video file or download if not cached
  Future<FileInfo> getVideoFile(String videoUrl, String reelId) async {
    final key = _keyPrefix + reelId;
    return await _cacheManager.getFileFromCache(key) ??
        await _cacheManager.downloadFile(videoUrl, key: key);
  }

  /// Check if video is cached and valid
  Future<bool> isVideoCached(String reelId) async {
    final key = _keyPrefix + reelId;
    final fileInfo = await _cacheManager.getFileFromCache(key);
    return fileInfo != null;
  }

  /// Clear specific video from cache
  Future<void> removeVideo(String reelId) async {
    final key = _keyPrefix + reelId;
    await _cacheManager.removeFile(key);
  }

  /// Clear all cached videos
  Future<void> clearAllVideos() async {
    await _cacheManager.emptyCache();
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      // Get all cache objects and sum their sizes
      final directory = await getTemporaryDirectory();
      final cacheDir = Directory(path.join(directory.path, 'reel_videos'));

      if (await cacheDir.exists()) {
        int totalSize = 0;
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size.toInt();
          }
        }
        return totalSize;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Pre-cache multiple videos in background
  Future<void> preCacheVideos(List<Map<String, String>> videoData) async {
    // Cache first 5 videos to avoid overwhelming the device
    final videosToCache = videoData.take(5);

    for (final video in videosToCache) {
      final videoUrl = video['videoUrl'];
      final reelId = video['reelId'];

      if (videoUrl != null && reelId != null) {
        // Don't await - let it cache in background
        preCache(videoUrl, reelId);
      }
    }
  }
}
