import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

/// Manages video player controllers with preloading and lifecycle management
/// to ensure smooth playback and optimal memory usage.
class VideoPreloadManager {
  final Logger _logger = Logger();

  // Map to store video controllers by reel ID
  final Map<String, VideoPlayerController> _controllers = {};

  // Keep track of order to manage memory
  final List<String> _controllerOrder = [];

  // Track which controllers are currently active/visible
  final Set<String> _activeControllers = {};

  // Maximum number of controllers to keep in memory
  static const int _maxControllers = 3;

  /// Initialize a video controller for the given reel
  Future<VideoPlayerController?> initializeController({
    required String reelId,
    required String videoUrl,
    bool autoPlay = false,
    bool isMuted = true,
  }) async {
    // If controller already exists, return it
    if (_controllers.containsKey(reelId)) {
      _logger.d('Reusing existing controller for reel: $reelId');
      return _controllers[reelId];
    }

    try {
      _logger.i('Initializing video controller for reel: $reelId');

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(isMuted ? 0.0 : 1.0);

      // Store the controller
      _controllers[reelId] = controller;
      _controllerOrder.add(reelId);

      // Clean up old controllers if we exceed the limit
      await _cleanupOldControllers();

      if (autoPlay) {
        await controller.play();
      }

      _logger.d('Controller initialized successfully for reel: $reelId');
      return controller;
    } catch (e) {
      _logger.e('Failed to initialize controller for reel $reelId: $e');
      return null;
    }
  }

  /// Preload video controllers for adjacent reels
  Future<void> preloadAdjacentVideos({
    required String currentReelId,
    required List<String> reelIds,
    required Map<String, String> videoUrls,
    int preloadCount = 1,
  }) async {
    final currentIndex = reelIds.indexOf(currentReelId);
    if (currentIndex == -1) return;

    // Preload next video(s)
    for (int i = 1; i <= preloadCount; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < reelIds.length) {
        final nextReelId = reelIds[nextIndex];
        final nextVideoUrl = videoUrls[nextReelId];

        if (nextVideoUrl != null && !_controllers.containsKey(nextReelId)) {
          _logger.d('Preloading next video: $nextReelId (offset: $i)');
          await initializeController(
            reelId: nextReelId,
            videoUrl: nextVideoUrl,
            autoPlay: false,
          );
        }
      }
    }

    // Optionally preload previous video for smooth backward scrolling
    if (currentIndex > 0) {
      final prevReelId = reelIds[currentIndex - 1];
      final prevVideoUrl = videoUrls[prevReelId];

      if (prevVideoUrl != null && !_controllers.containsKey(prevReelId)) {
        _logger.d('Preloading previous video: $prevReelId');
        await initializeController(
          reelId: prevReelId,
          videoUrl: prevVideoUrl,
          autoPlay: false,
        );
      }
    }
  }

  /// Get an existing controller
  VideoPlayerController? getController(String reelId) {
    return _controllers[reelId];
  }

  /// Check if a controller exists for the given reel
  bool hasController(String reelId) {
    return _controllers.containsKey(reelId);
  }

  /// Play a specific reel
  Future<void> play(String reelId) async {
    final controller = _controllers[reelId];
    if (controller != null && controller.value.isInitialized) {
      await controller.play();
    }
  }

  /// Pause a specific reel
  Future<void> pause(String reelId) async {
    final controller = _controllers[reelId];
    if (controller != null && controller.value.isInitialized) {
      await controller.pause();
    }
  }

  /// Pause all videos except the specified one
  Future<void> pauseAllExcept(String? activeReelId) async {
    for (final entry in _controllers.entries) {
      if (entry.key != activeReelId) {
        final controller = entry.value;
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
        }
      }
    }
  }

  /// Set volume for a specific controller
  Future<void> setVolume(String reelId, double volume) async {
    final controller = _controllers[reelId];
    if (controller != null && controller.value.isInitialized) {
      await controller.setVolume(volume);
    }
  }

  /// Mark a controller as active (currently visible)
  void markAsActive(String reelId) {
    _activeControllers.add(reelId);
  }

  /// Mark a controller as inactive (not visible)
  void markAsInactive(String reelId) {
    _activeControllers.remove(reelId);
  }

  /// Dispose a specific controller
  Future<void> disposeController(String reelId) async {
    // Don't dispose if the controller is currently active
    if (_activeControllers.contains(reelId)) {
      _logger.d('Skipping disposal of active controller: $reelId');
      return;
    }

    final controller = _controllers[reelId];
    if (controller != null) {
      _logger.d('Disposing controller for reel: $reelId');
      try {
        await controller.dispose();
      } catch (e) {
        _logger.e('Error disposing controller for $reelId: $e');
      }
      _controllers.remove(reelId);
      _controllerOrder.remove(reelId);
    }
  }

  /// Clean up old controllers to maintain memory limits
  Future<void> _cleanupOldControllers() async {
    while (_controllerOrder.length > _maxControllers) {
      // Find the oldest controller that is not active
      String? oldestInactiveReelId;
      for (final reelId in _controllerOrder) {
        if (!_activeControllers.contains(reelId)) {
          oldestInactiveReelId = reelId;
          break;
        }
      }

      // If we found an inactive controller, dispose it
      if (oldestInactiveReelId != null) {
        await disposeController(oldestInactiveReelId);
        _logger.d(
          'Cleaned up old controller: $oldestInactiveReelId (total: ${_controllerOrder.length})',
        );
      } else {
        // All controllers are active, can't clean up
        _logger.w('All controllers are active, cannot cleanup');
        break;
      }
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    _logger.i('Disposing all video controllers');
    _activeControllers.clear(); // Clear active tracking first
    for (final controller in _controllers.values) {
      try {
        await controller.dispose();
      } catch (e) {
        _logger.e('Error disposing controller: $e');
      }
    }
    _controllers.clear();
    _controllerOrder.clear();
  }

  /// Get the current number of active controllers
  int get activeControllerCount => _controllers.length;

  /// Get all managed reel IDs
  List<String> get managedReelIds => _controllerOrder.toList();
}
