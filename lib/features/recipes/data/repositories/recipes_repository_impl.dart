import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/recipes/data/datasources/recipes_remote_data_source.dart';
import 'package:one_atta/features/recipes/data/models/recipe_request_model.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/create_recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/entities/update_recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesRemoteDataSource remoteDataSource;

  RecipesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RecipeEntity>>> getAllRecipes() async {
    try {
      final result = await remoteDataSource.getAllRecipes();
      return Right(result.map((recipe) => recipe.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> getRecipeById(String id) async {
    try {
      final result = await remoteDataSource.getRecipeById(id);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> createRecipe(
    CreateRecipeEntity recipe,
  ) async {
    try {
      final createRecipeModel = CreateRecipeModel.fromEntity(recipe);
      final result = await remoteDataSource.createRecipe(createRecipeModel);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> updateRecipe(
    String id,
    UpdateRecipeEntity recipe,
  ) async {
    try {
      final updateRecipeModel = UpdateRecipeModel.fromEntity(recipe);
      final result = await remoteDataSource.updateRecipe(id, updateRecipeModel);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> deleteRecipe(String id) async {
    try {
      final result = await remoteDataSource.deleteRecipe(id);
      return Right(result.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleRecipeLike(
    String id,
  ) async {
    try {
      final result = await remoteDataSource.toggleRecipeLike(id);
      return Right(result);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getLikedRecipes() async {
    try {
      final result = await remoteDataSource.getLikedRecipes();
      return Right(result.map((recipe) => recipe.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
