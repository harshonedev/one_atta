import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';

class ToggleRecipeLike {
  final RecipesRepository repository;

  ToggleRecipeLike(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String recipeId) async {
    return await repository.toggleRecipeLike(recipeId);
  }
}
