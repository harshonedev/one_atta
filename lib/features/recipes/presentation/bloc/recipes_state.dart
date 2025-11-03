import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  final List<RecipeEntity> recipes;
  final List<RecipeEntity> filteredRecipes;
  final String selectedCategory;
  final String searchQuery;

  const RecipesLoaded({
    required this.recipes,
    required this.filteredRecipes,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  RecipesLoaded copyWith({
    List<RecipeEntity>? recipes,
    List<RecipeEntity>? filteredRecipes,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return RecipesLoaded(
      recipes: recipes ?? this.recipes,
      filteredRecipes: filteredRecipes ?? this.filteredRecipes,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    recipes,
    filteredRecipes,
    selectedCategory,
    searchQuery,
  ];
}

class RecipeDetailsLoading extends RecipesState {
  const RecipeDetailsLoading();
}

class RecipeDetailsLoaded extends RecipesState {
  final RecipeEntity recipe;

  const RecipeDetailsLoaded(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeCreating extends RecipesState {
  const RecipeCreating();
}

class RecipeCreated extends RecipesState {
  final RecipeEntity recipe;

  const RecipeCreated(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeUpdating extends RecipesState {
  const RecipeUpdating();
}

class RecipeUpdated extends RecipesState {
  final RecipeEntity recipe;

  const RecipeUpdated(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeDeleting extends RecipesState {
  const RecipeDeleting();
}

class RecipeDeleted extends RecipesState {
  final RecipeEntity recipe;

  const RecipeDeleted(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipesError extends RecipesState {
  final String message;
  final Failure? failure;

  const RecipesError(this.message, {this.failure});

  @override
  List<Object?> get props => [message, failure];
}

class LikedRecipesLoading extends RecipesState {
  const LikedRecipesLoading();
}

class LikedRecipesLoaded extends RecipesState {
  final List<RecipeEntity> likedRecipes;

  const LikedRecipesLoaded(this.likedRecipes);

  @override
  List<Object?> get props => [likedRecipes];
}
