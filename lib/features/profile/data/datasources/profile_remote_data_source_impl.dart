import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiRequest apiRequest;
  static final String baseUrl = ApiEndpoints.auth;
  static final String loyaltyBaseUrl = ApiEndpoints.loyalty;

  ProfileRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<UserProfileModel> getUserProfile(String token) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/profile',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? UserProfileModel.fromJson(response.data['data']['user'])
            : throw Exception(
                response.data['message'] ?? 'Failed to get user profile',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<UserProfileModel> updateProfile(
    String token,
    ProfileUpdateModel profileUpdate,
  ) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.put,
      url: '$baseUrl/profile',
      data: profileUpdate.toJson(),
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? UserProfileModel.fromJson(response.data['data']['user'])
            : throw Exception(
                response.data['message'] ?? 'Failed to update profile',
              ),
      ApiError() => throw response.failure,
    };
  }
}
