import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_event.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_state.dart';
import '../widgets/recipe_card.dart';

class LikedRecipesPage extends StatelessWidget {
  const LikedRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecipesBloc(repository: di.sl())..add(const LoadLikedRecipes()),
      child: const LikedRecipesView(),
    );
  }
}

class LikedRecipesView extends StatelessWidget {
  const LikedRecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Liked Recipes'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: BlocConsumer<RecipesBloc, RecipesState>(
        listener: (context, state) {
          if (state is RecipesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LikedRecipesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecipesError) {
            return ErrorPage(
              onRetry: () {
                context.read<RecipesBloc>().add(const LoadLikedRecipes());
              },
            );
          }

          if (state is LikedRecipesLoaded) {
            if (state.likedRecipes.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildLikedRecipesContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Liked Recipes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring recipes and tap the heart icon to save your favorites here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/recipes'),
              child: const Text('Explore Recipes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedRecipesContent(
    BuildContext context,
    LikedRecipesLoaded state,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.likedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = state.likedRecipes[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () => context.push('/recipes/${recipe.id}'),
        );
      },
    );
  }
}
