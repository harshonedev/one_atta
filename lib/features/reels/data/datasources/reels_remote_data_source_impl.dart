import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:one_atta/features/reels/data/models/reel_model.dart';

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/reels';

  ReelsRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<ReelsFeedModel> getReelsFeed({int? limit, String? cursor}) async {
    String requestUrl = baseUrl;
    final queryParams = <String>[];

    if (limit != null) queryParams.add('limit=$limit');
    if (cursor != null) queryParams.add('cursor=$cursor');

    if (queryParams.isNotEmpty) {
      requestUrl += '?${queryParams.join('&')}';
    }

    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: requestUrl,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? ReelsFeedModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch reels feed',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<int> incrementViewCount(String token, String id) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/$id/view',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? response.data['data']['views'] ?? 0
            : throw Exception(
                response.data['message'] ?? 'Failed to record view',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<ReelLikeResponse> toggleReelLike(String token, String reelId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/$reelId/like',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? ReelLikeResponse.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to toggle reel like',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<ReelShareResponse> shareReel(
    String token,
    String reelId, {
    String shareType = 'link',
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/$reelId/share',
      data: {'shareType': shareType},
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? ReelShareResponse.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to share reel',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<ReelLikeResponse> getReelLikedStatus(
    String token,
    String reelId,
  ) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/$reelId/like-status',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? ReelLikeResponse.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to get reel liked status',
              ),
      ApiError() => throw response.failure,
    };
  }
}
