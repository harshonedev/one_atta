import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/reels/domain/entities/reel_entity.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_event.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_state.dart';
import 'package:one_atta/features/reels/presentation/managers/video_preload_manager.dart';
import 'package:one_atta/features/reels/presentation/widgets/reel_item.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final VideoPreloadManager _videoManager = VideoPreloadManager();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Hide status bar for immersive experience
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoManager.disposeAll();
    // Restore status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  void _onReelView(String reelId) {
    context.read<ReelsBloc>()
      ..add(ReelLikedStatusRequested(reelId))
      ..add(IncrementReelView(reelId));
  }

  void _onPageChanged(int index, List<ReelEntity> reels) {
    setState(() {
      _currentIndex = index;
    });

    // Pause all videos except the current one
    if (index < reels.length) {
      _videoManager.pauseAllExcept(reels[index].id);
    }

    // Preload adjacent videos for smooth experience
    final reelIds = reels.map((r) => r.id).toList();
    final videoUrls = {for (var reel in reels) reel.id: reel.playbackUrl};

    _videoManager.preloadAdjacentVideos(
      currentReelId: reels[index].id,
      reelIds: reelIds,
      videoUrls: videoUrls,
      preloadCount: 1, // Preload next 1 video
    );

    // Load more reels when approaching the end (3 items before)
    final bloc = context.read<ReelsBloc>();
    final state = bloc.state;

    if (state is ReelsFeedLoaded &&
        index >= reels.length - 3 &&
        state.hasMore &&
        !state.isLoadingMore) {
      bloc.add(const LoadMoreReels());
    }
  }

  Future<void> _onRefresh() async {
    context.read<ReelsBloc>().add(const RefreshReelsFromServer());

    // Wait for the refresh to complete
    await context.read<ReelsBloc>().stream.firstWhere(
      (state) => state is! ReelsLoading,
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Play',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsContent(List<ReelEntity> reels) {
    if (reels.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      backgroundColor: Colors.black87,
      color: Colors.white,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) => _onPageChanged(index, reels),
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final reel = reels[index];
          final isCurrentReel = index == _currentIndex;

          return ReelItem(
            reel: reel,
            isVisible: isCurrentReel,
            onView: () => _onReelView(reel.id),
            autoPlay: true,
            videoManager: _videoManager,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      backgroundColor: Colors.black87,
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No reels available',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Check back later for new content',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    context.read<ReelsBloc>().add(
                      const RefreshReelsFromServer(),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      backgroundColor: Colors.black87,
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      context.read<ReelsBloc>().add(
                        const RefreshReelsFromServer(),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<ReelsBloc, ReelsState>(
        listener: (context, state) {
          if (state is ReelsFeedLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<ReelsBloc>().add(ClearErrorMessage());
          }
        },

        builder: (context, state) {
          return Stack(
            children: [
              // Main content
              if (state is ReelsLoading)
                _buildLoadingState()
              else if (state is ReelsError)
                _buildErrorState(state.message)
              else if (state is ReelsFeedLoaded)
                _buildReelsContent(state.reels)
              else
                _buildEmptyState(),

              // App bar overlay
              Positioned(top: 0, left: 0, right: 0, child: _buildAppBar()),

              // Loading more indicator at bottom
              if (state is ReelsFeedLoaded && state.isLoadingMore)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Loading more...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
