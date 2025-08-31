import 'package:equatable/equatable.dart';
import 'package:one_atta/features/recipes/domain/entities/create_recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/update_recipe_entity.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecipes extends RecipesEvent {
  const LoadRecipes();
}

class LoadRecipeDetails extends RecipesEvent {
  final String recipeId;

  const LoadRecipeDetails(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class CreateRecipe extends RecipesEvent {
  final CreateRecipeEntity recipe;

  const CreateRecipe(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class UpdateRecipe extends RecipesEvent {
  final String id;
  final UpdateRecipeEntity recipe;

  const UpdateRecipe(this.id, this.recipe);

  @override
  List<Object?> get props => [id, recipe];
}

class DeleteRecipe extends RecipesEvent {
  final String id;

  const DeleteRecipe(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterRecipesByCategory extends RecipesEvent {
  final String category;

  const FilterRecipesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchRecipes extends RecipesEvent {
  final String query;

  const SearchRecipes(this.query);

  @override
  List<Object?> get props => [query];
}
