import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/core/presentation/widgets/network_image_loader.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabController;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RecipeDetailsBloc>().add(LoadRecipeDetails(widget.recipeId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initializeYoutubePlayer(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onRetry: () {
                  // Get recipe ID from context or navigation
                },
              ),
            );
          }

          if (state is RecipeDetailsLoaded) {
            return _buildRecipeContent(context, state.recipe);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, RecipeEntity recipe) {
    // Initialize YouTube player if video URL exists
    if (recipe.videoUrl != null && _youtubeController == null) {
      _initializeYoutubePlayer(recipe.videoUrl!);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar with Recipe Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
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
              IconButton(
                onPressed: () => _toggleLike(context, recipe),
                icon: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.error,
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                  _buildRecipeStats(context, recipe),
                ],
              ),
            ),
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
            SliverToBoxAdapter(child: _buildYoutubePlayer()),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildRecipeStats(BuildContext context, RecipeEntity recipe) {
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
          _buildStatItem(context, Icons.favorite, '${recipe.likes}', 'Likes'),
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

  void _toggleLike(BuildContext context, RecipeEntity recipe) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Like feature coming soon!')));
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  radius: 15,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
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

  Widget _buildYoutubePlayer() {
    if (_youtubeController == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipe Video',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Theme.of(context).colorScheme.primary,
              progressColors: ProgressBarColors(
                playedColor: Theme.of(context).colorScheme.primary,
                handleColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
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
