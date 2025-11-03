import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_event.dart';
import 'package:one_atta/features/reels/presentation/managers/video_preload_manager.dart';
import 'package:one_atta/features/reels/presentation/widgets/reel_video_player.dart';
import 'package:share_plus/share_plus.dart';

class ReelItem extends StatefulWidget {
  final ReelEntity reel;
  final bool isVisible;
  final VoidCallback? onView;
  final bool autoPlay;
  final VideoPreloadManager? videoManager;

  const ReelItem({
    super.key,
    required this.reel,
    required this.isVisible,
    this.onView,
    this.autoPlay = true,
    this.videoManager,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _hasViewed = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.isVisible) {
      _startPlayback();
    }
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible && widget.autoPlay) {
        _startPlayback();
      } else {
        _stopPlayback();
      }
    }
  }

  void _startPlayback() {
    if (!_hasViewed) {
      _hasViewed = true;
      widget.onView?.call();
    }
    setState(() {
      _isPlaying = true;
    });
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _onVideoTap() {
    _togglePlayback();
  }

  void _onLike() {
    context.read<ReelsBloc>().add(ToggleReelLike(widget.reel.id));
  }

  void _onShare() {
    context.read<ReelsBloc>().add(ShareReel(widget.reel.id));
    // Also trigger native sharing
    final blendMessage = widget.reel.blend != null
        ? '"${widget.reel.blend!.name}" blend used in this play.  Checkout & Shop here: ${AppConstants.shareBaseUrl}/blend/${widget.reel.blend!.shareCode}\n'
        : '';
    final shareMessage =
        'Check out this amazing play! \n${widget.reel.caption} \n\nWatch on the play section in th app.\n\n$blendMessage';
    SharePlus.instance.share(
      ShareParams(
        text: shareMessage,
        title: 'OneAtta\'s Amazing Play',
        subject: "Check out this amazing play!",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get preloaded controller if available
    final preloadedController = widget.videoManager?.getController(
      widget.reel.id,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player (HLS from Cloudflare Stream)
          ReelVideoPlayer(
            videoUrl: widget.reel.playbackUrl,
            reelId: widget.reel.id,
            thumbnailUrl: widget.reel.thumbnailUrl,
            isPlaying: _isPlaying,
            isMuted: _isMuted,
            preloadedController: preloadedController,
            onTogglePlay: _togglePlayback,
            onToggleMute: _toggleMute,
            onVideoTap: _onVideoTap,
            onControllerActive: () {
              widget.videoManager?.markAsActive(widget.reel.id);
            },
            onControllerInactive: () {
              widget.videoManager?.markAsInactive(widget.reel.id);
            },
          ),

          // Right side controls
          Positioned(
            right: 12,
            bottom: 40,
            child: ReelVideoControls(
              isPlaying: _isPlaying,
              isMuted: _isMuted,
              views: widget.reel.views,
              likes: widget.reel.likes,
              shares: widget.reel.shares,
              isLiked: widget.reel.isLiked,
              onTogglePlay: _togglePlayback,
              onToggleMute: _toggleMute,
              onLike: _onLike,
              onShare: _onShare,
            ),
          ),

          // Bottom content overlay
          Positioned(
            left: 16,
            right: 80,
            bottom: 40,
            child: _buildContentOverlay(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator info
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.reel.createdBy.name.isNotEmpty
                    ? widget.reel.createdBy.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.reel.createdBy.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Caption
        if (widget.reel.caption.isNotEmpty)
          Text(
            widget.reel.caption,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 8),

        // Tags
        if (widget.reel.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.reel.tags
                .take(5)
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30, width: 0.5),
                    ),
                    child: Text(
                      '#$tag',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: 12),

        // Blend information (if available)
        if (widget.reel.blend != null) _buildBlendInfo(context),
      ],
    );
  }

  Widget _buildBlendInfo(BuildContext context) {
    final blend = widget.reel.blend!;

    return GestureDetector(
      onTap: () {
        if (widget.reel.blend?.id != null) {
          context.push('/blend-details/${widget.reel.blend!.id}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.blender, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    blend.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              'Tap to view blend details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
