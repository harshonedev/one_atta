import 'package:one_atta/features/recipes/data/models/recipe.dart';
import 'package:one_atta/features/recipes/data/models/recipe_request_model.dart';

abstract class RecipesRemoteDataSource {
  /// Get all recipes from the API
  Future<List<RecipeModel>> getAllRecipes();

  /// Get recipe by ID from the API
  Future<RecipeModel> getRecipeById(String id);

  /// Create a new recipe via the API
  Future<RecipeModel> createRecipe(CreateRecipeModel recipe);

  /// Update an existing recipe via the API
  Future<RecipeModel> updateRecipe(String id, UpdateRecipeModel recipe);

  /// Delete a recipe via the API
  Future<RecipeModel> deleteRecipe(String id);

  /// Toggle like status for a recipe via the API
  Future<Map<String, dynamic>> toggleRecipeLike(String id);

  /// Get liked recipes by user via the API
  Future<List<RecipeModel>> getLikedRecipes();
}
