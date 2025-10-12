import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_event.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_state.dart';
import '../widgets/recipe_card.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecipesBloc(repository: di.sl())..add(const LoadRecipes()),
      child: const RecipesView(),
    );
  }
}

class RecipesView extends StatefulWidget {
  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<RecipesBloc>().add(SearchRecipes(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Recipes'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _navigateToCart(context),
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Cart',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search recipes',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.inverseSurface.withValues(alpha: 0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Recipes List
          Expanded(
            child: BlocConsumer<RecipesBloc, RecipesState>(
              listener: (context, state) {
                if (state is RecipeCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Recipe created successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                } else if (state is RecipeDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Recipe deleted successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                } else if (state is RecipesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RecipesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RecipesError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is RecipesLoaded) {
                  return _buildRecipesContent(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return ErrorPage(
      onRetry: () {
        context.read<RecipesBloc>().add(const LoadRecipes());
      },
    );
  }

  Widget _buildRecipesContent(BuildContext context, RecipesLoaded state) {
    if (state.filteredRecipes.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RecipesBloc>().add(const LoadRecipes());
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: state.filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = state.filteredRecipes[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () {
              context.push('/recipe-details/${recipe.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recipes Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or create a new recipe.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    context.push('/cart');
  }
}
