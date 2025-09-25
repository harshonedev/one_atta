import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String posterUrl;
  final bool isPlaying;
  final bool isMuted;
  final VoidCallback? onTogglePlay;
  final VoidCallback? onToggleMute;
  final VoidCallback? onVideoTap;

  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.posterUrl,
    this.isPlaying = false,
    this.isMuted = true,
    this.onTogglePlay,
    this.onToggleMute,
    this.onVideoTap,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle play/pause state changes
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }

    // Handle mute state changes
    if (widget.isMuted != oldWidget.isMuted) {
      _controller?.setVolume(widget.isMuted ? 0.0 : 1.0);
    }

    // If video URL changed, reinitialize
    if (widget.videoUrl != oldWidget.videoUrl) {
      _reinitializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();

      _controller!.setLooping(true);
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);

      if (widget.isPlaying) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _reinitializeVideo() async {
    await _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background/Poster Image
        if (widget.posterUrl.isNotEmpty)
          Image.network(
            widget.posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              );
            },
          ),

        // Video Player
        if (_controller != null &&
            _controller!.value.isInitialized &&
            !_hasError)
          GestureDetector(
            onTap: widget.onVideoTap,
            child: VideoPlayer(_controller!),
          ),

        // Loading Indicator
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),

        // Error State
        if (_hasError)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load video',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _initializeVideo,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

        // Play/Pause Overlay
        if (!_isLoading && !_hasError)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onVideoTap ?? widget.onTogglePlay,
              child: AnimatedOpacity(
                opacity: widget.isPlaying ? 0.0 : 0.8,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black26,
                  child: widget.isPlaying
                      ? null
                      : const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 80,
                          ),
                        ),
                ),
              ),
            ),
          ),

        // Video Progress Indicator
        if (_controller != null &&
            _controller!.value.isInitialized &&
            widget.isPlaying)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: false,
              colors: VideoProgressColors(
                playedColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.8),
                bufferedColor: Colors.white.withValues(alpha: 0.3),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
      ],
    );
  }
}

class ReelVideoControls extends StatelessWidget {
  final bool isPlaying;
  final bool isMuted;
  final int views;
  final int likes;
  final int shares;
  final bool isLiked;
  final VoidCallback? onTogglePlay;
  final VoidCallback? onToggleMute;
  final VoidCallback? onLike;
  final VoidCallback? onShare;

  const ReelVideoControls({
    super.key,
    required this.isPlaying,
    required this.isMuted,
    required this.views,
    this.likes = 0,
    this.shares = 0,
    this.isLiked = false,
    this.onTogglePlay,
    this.onToggleMute,
    this.onLike,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause Button
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTogglePlay,
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),

        // Like Button
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onLike,
            icon: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isLiked ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
        ),

        // Likes Count
        if (likes > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              _formatCount(likes),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Share Button
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onShare,
            icon: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        // Shares Count
        if (shares > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              _formatCount(shares),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Mute/Unmute Button
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onToggleMute,
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        // Views Count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _formatCount(views),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
