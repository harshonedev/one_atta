import 'package:equatable/equatable.dart';

abstract class RecipeDetailsEvent extends Equatable {
  const RecipeDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecipeDetails extends RecipeDetailsEvent {
  final String recipeId;

  const LoadRecipeDetails(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class ToggleRecipeFavorite extends RecipeDetailsEvent {
  final String recipeId;

  const ToggleRecipeFavorite(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class ShareRecipe extends RecipeDetailsEvent {
  final String recipeId;

  const ShareRecipe(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class LikeRecipe extends RecipeDetailsEvent {
  final String recipeId;

  const LikeRecipe(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class LoadLikedRecipes extends RecipeDetailsEvent {
  const LoadLikedRecipes();

  @override
  List<Object?> get props => [];
}
