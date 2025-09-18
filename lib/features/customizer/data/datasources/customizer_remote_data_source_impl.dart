import 'package:dio/dio.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/customizer/data/datasources/customizer_remote_data_source.dart';
import 'package:one_atta/features/customizer/data/models/blend_analysis_model.dart';
import 'package:one_atta/features/customizer/data/models/blend_request_model.dart';
import 'package:logger/logger.dart';

class CustomizerRemoteDataSourceImpl implements CustomizerRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  CustomizerRemoteDataSourceImpl({
    required this.dio,
    required this.authLocalDataSource,
  });

  @override
  Future<BlendAnalysisModel> analyzeBlend(
    BlendRequestModel blendRequest,
  ) async {
    final logger = Logger();
    try {
      // Get token for  authentication
      final token = await authLocalDataSource.getToken();

      // Add authorization header if token is available
      if (token == null) {
        throw UnauthorizedFailure('No authentication token found');
      }

      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'x-api-key': AppConstants.appAPIKey,
        'Authorization': 'Bearer $token',
      };

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/blends/custom/analyze',
        data: blendRequest.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        logger.i('Successfully received blend analysis response');

        // Log the response structure for debugging
        logger.d('Response data structure: ${response.data}');

        try {
          return BlendAnalysisModel.fromJson(response.data);
        } catch (parseError) {
          logger.e('Failed to parse response data: $parseError');
          logger.e('Response data: ${response.data}');
          throw ServerFailure('Failed to parse server response: $parseError');
        }
      } else {
        logger.e('Failed to analyze blend: ${response.statusMessage}');
        throw ServerFailure(
          'Failed to analyze blend: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      logger.e('DioException in analyzeBlend: $e');
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            logger.e('Validation error: ${e.response!.data['error']}');
            throw ValidationFailure(
              e.response!.data['error'] ?? 'Invalid request data',
            );
          case 500:
            logger.e('Server error: ${e.response!.data['error']}');
            throw ServerFailure(
              e.response!.data['error'] ?? 'Internal server error',
            );
          default:
            logger.e('Server error: ${e.response!.statusCode}');
            throw ServerFailure('Server error: ${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        logger.e('Connection timeout');
        throw NetworkFailure('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        logger.e('No internet connection');
        throw NetworkFailure('No internet connection');
      } else {
        logger.e('Network error: ${e.message}');
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      logger.e('Unexpected error in analyzeBlend: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<SavedBlendModel> saveBlend(SaveBlendModel saveBlendRequest) async {
    final logger = Logger();
    try {
      final token = await authLocalDataSource.getToken();
      if (token == null) {
        logger.e('No authentication token found');
        throw UnauthorizedFailure('No authentication token found');
      }

      final response = await dio.post(
        '${ApiEndpoints.baseUrl}/blends',
        data: saveBlendRequest.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.appAPIKey,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data']['blend'];
        return SavedBlendModel.fromJson(data);
      } else {
        logger.e('Failed to save blend: ${response.statusMessage}');
        throw ServerFailure('Failed to save blend: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      logger.e('DioException in saveBlend: $e');
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            logger.e('Validation error: ${e.response!.data['message']}');
            throw ValidationFailure(
              e.response!.data['message'] ?? 'Invalid request data',
            );
          case 401:
            logger.e('Unauthorized: ${e.response!.data['message']}');
            throw UnauthorizedFailure(
              e.response!.data['message'] ?? 'Unauthorized',
            );
          case 404:
            logger.e('Resource not found: ${e.response!.data['message']}');
            throw ServerFailure(
              e.response!.data['message'] ?? 'Resource not found',
            );
          case 500:
            logger.e('Internal server error: ${e.response!.data['message']}');
            throw ServerFailure(
              e.response!.data['message'] ?? 'Internal server error',
            );
          default:
            logger.e('Server error: ${e.response!.statusCode}');
            throw ServerFailure('Server error: ${e.response!.statusCode}');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        logger.e('Connection timeout');
        throw NetworkFailure('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        logger.e('No internet connection');
        throw NetworkFailure('No internet connection');
      } else {
        logger.e('Network error: ${e.message}');
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      logger.e('Unexpected error in saveBlend: $e');
      if (e is Failure) rethrow;
      throw ServerFailure('Unexpected error: $e');
    }
  }
}
