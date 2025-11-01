import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/daily_essentials/data/datasources/daily_essentials_remote_data_source.dart';
import 'package:one_atta/features/daily_essentials/domain/entities/daily_essential_entity.dart';
import 'package:one_atta/features/daily_essentials/domain/repositories/daily_essentials_repository.dart';

class DailyEssentialsRepositoryImpl implements DailyEssentialsRepository {
  final DailyEssentialsRemoteDataSource remoteDataSource;

  final Logger logger = Logger();

  DailyEssentialsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DailyEssentialEntity>>> getAllProducts({
    bool? isSeasonal,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getAllProducts(
        isSeasonal: isSeasonal,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
      );

      return Right(
        result.data.products.map((product) => product.toEntity()).toList(),
      );
    } on Failure catch (failure) {
      logger.e('Error in getAllProducts: $failure');
      return Left(failure);
    } catch (e) {
      logger.e('Unexpected error in getAllProducts: $e');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyEssentialEntity>> getProductById(
    String id,
  ) async {
    try {
      final result = await remoteDataSource.getProductById(id);
      return Right(result.data.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
