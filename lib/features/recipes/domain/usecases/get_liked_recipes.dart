import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/recipes/domain/entities/recipe_entity.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';

class GetLikedRecipes {
  final RecipesRepository repository;

  GetLikedRecipes(this.repository);

  Future<Either<Failure, List<RecipeEntity>>> call() async {
    return await repository.getLikedRecipes();
  }
}
