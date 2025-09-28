import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';

class ApiRequest {
  final Dio dio;
  final Logger logger = Logger();

  ApiRequest({required this.dio});

  Future<ApiResponse> callRequest({
    required HttpMethod method,
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? data,
    String? token,
  }) async {
    try {
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'x-api-key': AppConstants.appAPIKey,
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await dio.request(
        url,
        options: Options(
          method: method.name.toUpperCase(),
          headers: requestHeaders,
        ),
        data: data,
      );

      logger.i(
        '✅ ${method.name.toUpperCase()} Request to $url completed with status code ${response.statusCode}',
      );
      // log response data for debugging
      logger.d('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiSuccess<Map<String, dynamic>>(response.data);
      } else {
        logger.w(
          '$method Request to $url returned status code ${response.statusCode}',
        );
        return ApiError(ServerFailure('Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      logger.e(
        '❌ DioException in ${method.name.toUpperCase()} Request to $url: ${e.message}',
      );

      if (e.response != null) {
        logger.e('📥 Error Response Data: ${e.response!.data}');
        logger.e('🔢 Status Code: ${e.response!.statusCode}');

        switch (e.response!.statusCode) {
          case 400:
            logger.e('❌ Bad request to $url: ${e.response!.data}');
            return ApiError(
              ValidationFailure(
                e.response!.data['message'] ?? 'Invalid request',
              ),
            );
          case 404:
            logger.e(
              '❌ Endpoint not found: $url - Response: ${e.response!.data}',
            );
            return ApiError(
              ServerFailure(
                e.response!.data['message'] ?? 'Resource not found',
              ),
            );
          case 500:
            logger.e('Server error: ${e.response!.data}');
            return ApiError(
              ServerFailure(
                e.response!.data['message'] ?? 'Internal server error',
              ),
            );
          default:
            logger.e('Server error: ${e.response!.statusCode}');
            return ApiError(
              ServerFailure('Server error: ${e.response!.statusCode}'),
            );
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        logger.e('Connection timeout');
        return ApiError(NetworkFailure('Connection timeout'));
      } else if (e.type == DioExceptionType.connectionError) {
        logger.e('No internet connection');
        return ApiError(NetworkFailure('No internet connection'));
      } else {
        logger.e('Network error: ${e.message}');
        return ApiError(ServerFailure('Network error: ${e.message}'));
      }
    } catch (e) {
      logger.e('Unexpected error in $method request: $e');
      if (e is Failure) return ApiError(e);
      return ApiError(ServerFailure('Unexpected error: $e'));
    }
  }
}

sealed class ApiResponse<T> {}

class ApiSuccess<T> extends ApiResponse<T> {
  final T data;
  ApiSuccess(this.data);
}

class ApiError<T> extends ApiResponse<T> {
  final Failure failure;
  ApiError(this.failure);
}

enum HttpMethod { get, post, put, delete }
