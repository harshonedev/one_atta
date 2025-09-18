import 'package:dio/dio.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/blends/data/datasources/blends_remote_data_source.dart';
import 'package:one_atta/features/blends/data/models/blend_model.dart';
import 'package:one_atta/features/blends/data/models/blend_request_model.dart';

class BlendsRemoteDataSourceImpl implements BlendsRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/blends';

  BlendsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PublicBlendModel>> getAllPublicBlends() async {
    try {
      final response = await dio.get(baseUrl);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> blendsData = response.data['data']['blends'];
        return blendsData
            .map((blend) => PublicBlendModel.fromJson(blend))
            .toList();
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch public blends',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to fetch public blends';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<BlendModel> createBlend(CreateBlendModel blend) async {
    try {
      final response = await dio.post(baseUrl, data: blend.toJson());

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BlendModel.fromJson(response.data['data']['blend']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to create blend',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message = e.response?.data?['message'] ?? 'Failed to create blend';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<BlendDetailsModel> getBlendDetails(String id, String token) async {
    try {
      // add bearer token to headerr
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.get('$baseUrl/$id');

      if (response.statusCode == 200) {
        return BlendDetailsModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch blend details',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to fetch blend details';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<String> shareBlend(String id) async {
    try {
      final response = await dio.post('$baseUrl/$id/share');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['share_code'];
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to share blend',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message = e.response?.data?['message'] ?? 'Failed to share blend';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> subscribeToBlend(String id) async {
    try {
      final response = await dio.post('$baseUrl/$id/subscribe');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to subscribe to blend',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to subscribe to blend';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<BlendModel> updateBlend(String id, UpdateBlendModel blend) async {
    try {
      final response = await dio.put('$baseUrl/$id', data: blend.toJson());

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BlendModel.fromJson(response.data['data']['blend']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to update blend',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message = e.response?.data?['message'] ?? 'Failed to update blend';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<PublicBlendModel> getBlendByShareCode(String shareCode) async {
    try {
      final response = await dio.get('$baseUrl/by-share-code/$shareCode');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PublicBlendModel.fromJson(response.data['data']['blend']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch blend by share code',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to fetch blend by share code';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
