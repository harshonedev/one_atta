import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/core/presentation/widgets/network_image_loader.dart';
import 'package:one_atta/features/recipes/domain/entities/blend_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_event.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_state.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailsPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  YoutubePlayerController? _youtubeController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RecipeDetailsBloc>().add(LoadRecipeDetails(widget.recipeId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController?.removeListener(_youtubePlayerListener);
    _youtubeController?.dispose();
    // Reset orientation preferences when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _initializeYoutubePlayer(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
          hideControls: false,
          forceHD: false,
        ),
      )..addListener(_youtubePlayerListener);
    }
  }

  void _youtubePlayerListener() {
    if (_youtubeController != null && mounted) {
      // Handle fullscreen changes
      if (_youtubeController!.value.isFullScreen) {
        // Lock orientation to landscape when in fullscreen
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        // Reset orientation when exiting fullscreen
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<RecipeDetailsBloc, RecipeDetailsState>(
        listener: (context, state) {
          if (state is RecipeDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RecipeDetailsLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is RecipeDetailsError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Recipe Details'),
                centerTitle: false,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              body: ErrorPage(
                failure: state.failure,
                onRetry: () {
                  // Get recipe ID from context or navigation
                  context.read<RecipeDetailsBloc>().add(
                    LoadRecipeDetails(widget.recipeId),
                  );
                },
              ),
            );
          }

          if (state is RecipeDetailsLoaded) {
            return _buildRecipeContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, RecipeDetailsLoaded state) {
    final recipe = state.recipe;

    // Initialize YouTube player if video URL exists
    if (recipe.videoUrl != null && _youtubeController == null) {
      _initializeYoutubePlayer(recipe.videoUrl!);
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
        progressColors: ProgressBarColors(
          playedColor: Theme.of(context).colorScheme.primary,
          handleColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      builder: (context, player) {
        return CustomScrollView(
          slivers: [
            // App Bar with Recipe Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              leading: Container(
                margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Recipe Image
                    Positioned.fill(
                      child: NetworkImageLoader(
                        imageUrl: recipe.recipePicture ?? '',
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: state.isLiking
                        ? null
                        : () => _toggleLike(context, recipe.id),
                    icon: state.isLiking
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        : Icon(
                            state.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: state.isLiked
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                  ),
                ),
              ],
            ),

            // Recipe Title and Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (recipe.description?.isNotEmpty == true) ...[
                      Text(
                        recipe.description!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Recipe Stats
                    _buildRecipeStats(context, recipe, state),
                  ],
                ),
              ),
            ),

            // Blend Information Section
            if (recipe.blendUsed != null)
              SliverToBoxAdapter(
                child: _buildBlendInformation(context, recipe.blendUsed!),
              ),

            // Tab Bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Ingredients'),
                    Tab(text: 'Instructions'),
                  ],
                ),
              ),
              pinned: true,
            ),

            // Tab Content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  return IndexedStack(
                    index: _tabController.index,
                    children: [
                      _buildIngredientsTab(context, recipe),
                      _buildInstructionsTab(context, recipe),
                    ],
                  );
                },
              ),
            ),

            // YouTube Video Player
            if (recipe.videoUrl != null && _youtubeController != null)
              SliverToBoxAdapter(child: _buildYoutubePlayer(player)),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }

  Widget _buildRecipeStats(
    BuildContext context,
    RecipeEntity recipe,
    RecipeDetailsLoaded state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.list_alt,
            '${recipe.ingredients.length}',
            'Ingredients',
          ),
          _buildStatItem(
            context,
            Icons.format_list_numbered,
            '${recipe.steps.length}',
            'Steps',
          ),
          _buildStatItem(
            context,
            Icons.favorite,
            state.isLiking ? '...' : '${state.likesCount}',
            'Likes',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _toggleLike(BuildContext context, String recipeId) {
    context.read<RecipeDetailsBloc>().add(LikeRecipe(recipeId));
  }

  Widget _buildBlendInformation(
    BuildContext context,
    RecipeBlendEntity blendUsed,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/blend-details/${blendUsed.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Premium Badge
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blendUsed.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),

                if (blendUsed.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    blendUsed.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: 'View Blend Details',
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/blend-details/${blendUsed.id}');
                          },
                          icon: Icon(
                            Icons.visibility,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            'View Details',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsTab(BuildContext context, RecipeEntity recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: recipe.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 15,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              ingredient.name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${ingredient.quantity} ${ingredient.unit}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionsTab(BuildContext context, RecipeEntity recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: recipe.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 15,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildYoutubePlayer(Widget player) {
    if (_youtubeController == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipe Video',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(12), child: player),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
