import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/create_recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/update_recipe_entity.dart';

abstract class RecipesRepository {
  /// Get all recipes
  Future<Either<Failure, List<RecipeEntity>>> getAllRecipes();

  /// Get recipe by ID
  Future<Either<Failure, RecipeEntity>> getRecipeById(String id);

  /// Create a new recipe
  Future<Either<Failure, RecipeEntity>> createRecipe(CreateRecipeEntity recipe);

  /// Update an existing recipe
  Future<Either<Failure, RecipeEntity>> updateRecipe(
    String id,
    UpdateRecipeEntity recipe,
  );

  /// Delete a recipe
  Future<Either<Failure, RecipeEntity>> deleteRecipe(String id);
}
