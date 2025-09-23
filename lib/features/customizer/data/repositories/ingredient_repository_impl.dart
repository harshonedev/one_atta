import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/customizer/data/datasources/customizer_remote_data_source.dart';
import 'package:one_atta/features/customizer/domain/entities/ingredient_entity.dart';
import 'package:one_atta/features/customizer/domain/repositories/ingredient_repository.dart';

/// Implementation of [IngredientRepository]
///
/// This class implements the ingredient repository interface using
/// the remote data source for API calls.
class IngredientRepositoryImpl implements IngredientRepository {
  final CustomizerRemoteDataSource remoteDataSource;
  final logger = Logger();

  IngredientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<IngredientEntity>>> getIngredients() async {
    try {
      logger.i('Fetching ingredients from repository');
      final result = await remoteDataSource.getIngredients();

      // Convert models to entities
      final entities = result
          .map((model) => model as IngredientEntity)
          .toList();

      logger.i('Successfully fetched ${entities.length} ingredients');
      return Right(entities);
    } on Failure catch (failure) {
      logger.e('Failed to fetch ingredients: ${failure.toString()}');
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error in getIngredients: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
