import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/customizer/domain/entities/ingredient_entity.dart';

/// Repository interface for ingredient operations
///
/// This defines the contract for ingredient data operations
/// following Clean Architecture principles.
abstract class IngredientRepository {
  /// Fetch all available ingredients from the API
  ///
  /// Returns a list of ingredients that users can use for blend creation.
  /// This corresponds to the GET /api/ingredients endpoint.
  ///
  /// Returns:
  /// - [Right<List<IngredientEntity>>] on success
  /// - [Left<Failure>] on error (network, server, etc.)
  Future<Either<Failure, List<IngredientEntity>>> getIngredients();
}
