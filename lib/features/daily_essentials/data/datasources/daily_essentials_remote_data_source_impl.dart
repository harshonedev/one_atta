import 'package:dio/dio.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/daily_essentials/data/datasources/daily_essentials_remote_data_source.dart';
import 'package:one_atta/features/daily_essentials/data/models/products_api_response.dart';

class DailyEssentialsRemoteDataSourceImpl
    implements DailyEssentialsRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/products';

  DailyEssentialsRemoteDataSourceImpl({required this.dio});

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
    try {
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

      final response = await dio.get(baseUrl, queryParameters: queryParams);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProductsApiResponse.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch products',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to fetch products';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<SingleProductApiResponse> getProductById(String id) async {
    try {
      final response = await dio.get('$baseUrl/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SingleProductApiResponse.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch product',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      if (e.response?.statusCode == 404) {
        throw const ServerFailure('Product not found or unavailable');
      }

      final message = e.response?.data?['message'] ?? 'Failed to fetch product';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
