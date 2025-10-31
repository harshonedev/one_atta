import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'package:one_atta/core/presentation/widgets/cart_icon_button.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/home/presentation/bloc/home_event.dart';
import 'package:one_atta/features/home/presentation/bloc/home_state.dart';
import 'package:one_atta/features/home/presentation/widgets/blend_card.dart';
import 'package:one_atta/features/home/presentation/widgets/daily_essentials_blend_card.dart';
import 'package:one_atta/features/home/presentation/widgets/recipe_card.dart';
import 'package:one_atta/features/home/presentation/widgets/section_header.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load home data when the page is initialized
    context.read<HomeBloc>().add(const LoadHomeData());
    context.read<UserProfileBloc>().add(GetUserProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/onboarding');
          }
        },
        child: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return _buildLoadingContent(context);
              }

              if (state is HomeError && state.trendingBlends.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(const LoadHomeData());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is HomeLoaded) {
                return _buildHomeContent(context, state);
              }

              if (state is HomeError) {
                // Show error but with existing data
                return _buildHomeContentWithError(context, state);
              }

              if (state is HomePartialLoading) {
                return _buildHomeContentWithLoading(context, state);
              }

              if (state is HomeSearchResult) {
                return _buildSearchResults(context, state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        UserEntity? user;
        if (authState is AuthAuthenticated) {
          user = authState.user;
        }

        return Column(
          children: [
            _buildHeader(context, user),
            _buildCreateAttaSection(context),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshHomeData());
        context.read<UserProfileBloc>().add(GetUserProfileRequested());
      },
      child: Column(
        children: [
          _buildHeader(context, state.user),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Create Your Perfect Atta Section
                SliverToBoxAdapter(child: _buildCreateAttaSection(context)),

                // Ready to Sell Blends Section
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Daily Essentials'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return DailyEssentialsBlendCard(
                        blend: state.readyToSellBlends[index],
                        isCompact: true,
                        onTap: () {
                          // Navigate to daily essential details
                          String productId = state.readyToSellBlends[index].id;

                          context.push('/daily-essential-details/$productId');
                        },
                      );
                    }, childCount: state.readyToSellBlends.length),
                  ),
                ),

                // Trending Blends Section
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Trending Blends',
                    actionText: 'See All',
                    onActionPressed: () {
                      context.push('/blends');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.trendingBlends.length,
                      itemBuilder: (context, index) {
                        final blend = state.trendingBlends[index];
                        return BlendCard(
                          blend: blend,
                          onTap: () {
                            context.push('/blend-details/${blend.id}');
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Recipes Section
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Latest Recipes',
                    actionText: 'See All',
                    onActionPressed: () {
                      context.go('/recipes');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.featuredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = state.featuredRecipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          onTap: () {
                            context.push('/recipe-details/${recipe.id}');
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Review Section
                SliverToBoxAdapter(child: _buildRewardsSection(context)),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity? user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Profile picture and greeting
          Row(
            children: [
              InkWell(
                onTap: () {
                  // Navigate to profile page
                  context.push('/profile');
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              BlocBuilder<UserProfileBloc, UserProfileState>(
                builder: (context, state) {
                  final points = state is UserProfileLoaded
                      ? state.profile.loyaltyPoints
                      : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user?.name ?? 'User'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '$points Atta Points',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          const Spacer(),

          // Notification icon
          IconButton(
            onPressed: () {
              // Navigate to notifications
            },
            icon: Stack(
              children: [
                SvgPicture.asset(
                  AppAssets.notificationsIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cart icon
          CartIconButton(),
        ],
      ),
    );
  }

  Widget _buildCreateAttaSection(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/customizer'),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Your One Atta',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '100% Preservative Free',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customize your blend with our interactive builder',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStepItem(context, Icons.grain_rounded, 'Select', false),

                _buildStepItem(context, Icons.blender_rounded, 'Mix', false),

                _buildStepItem(
                  context,
                  Icons.pie_chart_rounded,
                  'Preview',
                  false,
                ),

                _buildStepItem(
                  context,
                  Icons.shopping_bag_rounded,
                  'Confirm',
                  true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContentWithError(BuildContext context, HomeError state) {
    return Column(
      children: [
        _buildHeader(context, state.user),
        Container(
          width: double.infinity,
          color: Colors.red.shade50,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const RefreshHomeData());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildHomeContentData(
            context,
            state.user,
            state.trendingBlends,
            state.featuredRecipes,
            state.readyToSellBlends,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContentWithLoading(
    BuildContext context,
    HomePartialLoading state,
  ) {
    return Column(
      children: [
        _buildHeader(context, state.user),
        if (state.isLoadingBlends ||
            state.isLoadingRecipes ||
            state.isLoadingUser)
          const LinearProgressIndicator(),
        Expanded(
          child: _buildHomeContentData(
            context,
            state.user,
            state.trendingBlends,
            state.featuredRecipes,
            state.readyToSellBlends,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, HomeSearchResult state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadHomeData());
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  'Search results for "${state.query}"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        if (state.isLoading)
          const LinearProgressIndicator()
        else if (state.searchResults.isEmpty)
          const Expanded(child: Center(child: Text('No blends found')))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.searchResults.length,
              itemBuilder: (context, index) {
                final blend = state.searchResults[index];
                return BlendCard(
                  blend: blend,
                  isHorizontal: true,
                  onTap: () {
                    context.push('/blend-details/${blend.id}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          // Navigate to reviews page
          context.push('/rewards');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.giftIcon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View Rewards',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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
        ),
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isLastItem,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            if (!isLastItem)
              Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContentData(
    BuildContext context,
    UserEntity? user,
    List<PublicBlendEntity> trendingBlends,
    List<RecipeEntity> featuredRecipes,
    List<BlendItem> readyToSellBlends,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshHomeData());
      },
      child: CustomScrollView(
        slivers: [
          // Create Your Perfect Atta Section
          SliverToBoxAdapter(child: _buildCreateAttaSection(context)),

          // Ready to Sell Blends Section
          SliverToBoxAdapter(child: SectionHeader(title: 'Daily Essentials')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return DailyEssentialsBlendCard(
                  blend: readyToSellBlends[index],
                  isCompact: true,
                  onTap: () {
                    // Navigate to daily essential details
                    String productId = readyToSellBlends[index].id;

                    context.push('/daily-essential-details/$productId');
                  },
                );
              }, childCount: readyToSellBlends.length),
            ),
          ),

          // Trending Blends Section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Trending Blends',
              actionText: 'See All',
              onActionPressed: () {
                context.push('/blends');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trendingBlends.length,
                itemBuilder: (context, index) {
                  final blend = trendingBlends[index];
                  return BlendCard(
                    blend: blend,
                    onTap: () {
                      context.push('/blend-details/${blend.id}');
                    },
                  );
                },
              ),
            ),
          ),

          // Recipes Section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Latest Recipes',
              actionText: 'See All',
              onActionPressed: () {
                context.go('/recipes');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featuredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = featuredRecipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    onTap: () {
                      context.push('/recipe-details/${recipe.id}');
                    },
                  );
                },
              ),
            ),
          ),

          // Review Section
          SliverToBoxAdapter(child: _buildRewardsSection(context)),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
