import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/daily_essentials/data/datasources/daily_essentials_remote_data_source.dart';
import 'package:one_atta/features/daily_essentials/data/models/products_api_response.dart';

class DailyEssentialsRemoteDataSourceImpl
    implements DailyEssentialsRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/products';

  DailyEssentialsRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<ProductsApiResponse> getAllProducts({
    bool? isSeasonal,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) async {
    // Build query parameters
    final queryParams = <String, dynamic>{};

    if (isSeasonal != null) queryParams['isSeasonal'] = isSeasonal.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams['sortOrder'] = sortOrder;
    }
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    // Create URL with query parameters
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: uri.toString(),
    );

    return switch (response) {
      ApiSuccess() => response.data['success'] == true
          ? ProductsApiResponse.fromJson(response.data)
          : throw Exception(response.data['message'] ?? 'Failed to fetch products'),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<SingleProductApiResponse> getProductById(String id) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/$id',
    );

    return switch (response) {
      ApiSuccess() => response.data['success'] == true
          ? SingleProductApiResponse.fromJson(response.data)
          : throw Exception(response.data['message'] ?? 'Failed to fetch product'),
      ApiError() => throw response.failure,
    };
  }
}