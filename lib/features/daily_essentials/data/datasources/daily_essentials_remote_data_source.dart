import 'package:one_atta/features/daily_essentials/data/models/products_api_response.dart';

abstract class DailyEssentialsRemoteDataSource {
  /// Get all available products from app API
  Future<ProductsApiResponse> getAllProducts({
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
  Future<SingleProductApiResponse> getProductById(String id);
}
