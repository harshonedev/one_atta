import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/loyalty_points_response_model.dart';
import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart'
    hide LoyaltyPointsResponseModel, RedemptionResponseModel;
import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/data/models/redemption_response_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiRequest apiRequest;
  static final String baseUrl = ApiEndpoints.auth;
  static final String loyaltyBaseUrl = '${ApiEndpoints.baseUrl}/loyalty';

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
            ? UserProfileModel.fromJson(response.data)
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
            ? UserProfileModel.fromJson(response.data)
            : throw Exception(
                response.data['message'] ?? 'Failed to update profile',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<LoyaltyPointsResponseModel> earnPointsFromOrder({
    required String token,
    required double amount,
    required String orderId,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$loyaltyBaseUrl/earn/order',
      data: {'amount': amount, 'orderId': orderId},
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? LoyaltyPointsResponseModel.fromJson(response.data)
            : throw Exception(
                response.data['message'] ?? 'Failed to earn points from order',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<LoyaltyPointsResponseModel> earnPointsFromShare({
    required String token,
    required String blendId,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$loyaltyBaseUrl/earn/share',
      data: {'blendId': blendId},
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? LoyaltyPointsResponseModel.fromJson(response.data)
            : throw Exception(
                response.data['message'] ?? 'Failed to earn points from share',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<LoyaltyPointsResponseModel> earnPointsFromReview({
    required String token,
    required String reviewId,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$loyaltyBaseUrl/earn/review',
      data: {'reviewId': reviewId},
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? LoyaltyPointsResponseModel.fromJson(response.data)
            : throw Exception(
                response.data['message'] ?? 'Failed to earn points from review',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<RedemptionResponseModel> redeemPoints({
    required String token,
    required String orderId,
    required int pointsToRedeem,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$loyaltyBaseUrl/redeem',
      data: {'orderId': orderId, 'pointsToRedeem': pointsToRedeem},
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? RedemptionResponseModel.fromJson(response.data)
            : throw Exception(
                response.data['message'] ?? 'Failed to redeem points',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactionHistory({
    required String token,
    required String userId,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$loyaltyBaseUrl/history/$userId',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List<dynamic>)
                  .map((json) => LoyaltyTransactionModel.fromJson(json))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to get loyalty history',
              ),
      ApiError() => throw response.failure,
    };
  }
}
