import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/daily_essentials/domain/entities/daily_essential_entity.dart';

abstract class DailyEssentialsRepository {
  /// Get all available products from app API
  Future<Either<Failure, List<DailyEssentialEntity>>> getAllProducts({
    bool? isSeasonal,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  });

  /// Get product by ID from app API
  Future<Either<Failure, DailyEssentialEntity>> getProductById(String id);
}
