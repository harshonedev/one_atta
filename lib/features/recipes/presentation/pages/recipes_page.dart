import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/recipes_bloc.dart';
import '../bloc/recipes_event.dart';
import '../bloc/recipes_state.dart';
import '../widgets/recipe_search_bar.dart';
import '../widgets/category_filter.dart';
import '../widgets/featured_recipe_card.dart';
import '../widgets/recipe_card.dart';
import '../widgets/community_section.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    context.read<RecipesBloc>().add(const LoadRecipes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<RecipesBloc>().add(SearchRecipes(query));
  }

  void _onCategorySelected(String category) {
    context.read<RecipesBloc>().add(FilterRecipesByCategory(category));
  }

  void _onRecipeTap(String recipeId) {
    context.push('/recipe-details/$recipeId');
  }

  void _onJoinCommunity() {
    // Handle join community action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Join community feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<RecipesBloc, RecipesState>(
          builder: (context, state) {
            if (state is RecipesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecipesError) {
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
                      'Error loading recipes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        context.read<RecipesBloc>().add(const LoadRecipes());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is RecipesLoaded) {
              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    snap: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.all(16),
                      title: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Recipes',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecipeSearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: () => _onSearchChanged(''),
                      ),
                    ),
                  ),

                  // Category Filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: CategoryFilter(
                        categories: _categories,
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),
                    ),
                  ),

                  // Featured Recipes Section
                  if (state.featuredRecipes.isNotEmpty &&
                      state.selectedCategory == 'All' &&
                      state.searchQuery.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Featured Recipes',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 16,
                            bottom: 8,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.featuredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = state.featuredRecipes[index];
                            return FeaturedRecipeCard(
                              recipe: recipe,
                              onTap: () => _onRecipeTap(recipe.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // All Recipes List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        state.searchQuery.isNotEmpty
                            ? 'Search Results (${state.recipes.length})'
                            : state.selectedCategory == 'All'
                            ? 'All Recipes'
                            : '${state.selectedCategory} Recipes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Recipes List
                  if (state.recipes.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recipes found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter criteria',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final recipe = state.recipes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: RecipeCard(
                            recipe: recipe,
                            onTap: () => _onRecipeTap(recipe.id),
                          ),
                        );
                      }, childCount: state.recipes.length),
                    ),

                  // Community Section
                  if (state.selectedCategory == 'All' &&
                      state.searchQuery.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: CommunitySection(
                          members: state.communityMembers,
                          onJoinPressed: _onJoinCommunity,
                        ),
                      ),
                    ),

                  // Bottom Spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
