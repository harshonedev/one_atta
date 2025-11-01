import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/blends/data/datasources/blends_remote_data_source.dart';
import 'package:one_atta/features/blends/data/models/blend_model.dart';
import 'package:one_atta/features/blends/data/models/blend_request_model.dart';

class BlendsRemoteDataSourceImpl implements BlendsRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/blends';

  BlendsRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<List<PublicBlendModel>> getAllPublicBlends() async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: baseUrl,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data']['blends'] as List<dynamic>)
                  .map((blend) => PublicBlendModel.fromJson(blend))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch public blends',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<BlendModel> createBlend(CreateBlendModel blend) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: baseUrl,
      data: blend.toJson(),
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? BlendModel.fromJson(response.data['data']['blend'])
            : throw Exception(
                response.data['message'] ?? 'Failed to create blend',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<BlendDetailsModel> getBlendDetails(String id, String token) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/$id',
      token: token,
    );

    return switch (response) {
      ApiSuccess() => BlendDetailsModel.fromJson(response.data),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<BlendModel>> getUserBlends(String token) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/my-blends',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data']['blends'] as List<dynamic>)
                  .map((blend) => BlendModel.fromJson(blend))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to get user blends',
              ),
      ApiError() => throw response.failure,
    };
  }
}
