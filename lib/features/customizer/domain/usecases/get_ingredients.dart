import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/customizer/domain/entities/ingredient_entity.dart';
import 'package:one_atta/features/customizer/domain/repositories/ingredient_repository.dart';

/// Use case for fetching ingredients
///
/// This use case handles the business logic for retrieving
/// all available ingredients from the repository.
class GetIngredientsUseCase {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  Future<Either<Failure, List<IngredientEntity>>> call() async {
    return await repository.getIngredients();
  }
}
