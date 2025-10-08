import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/loyalty/data/models/loyalty_points_response_model.dart';
import 'package:one_atta/features/loyalty/data/models/loyalty_transaction_model.dart';

abstract class LoyaltyRemoteDataSource {
  /// Earn points from order
  Future<LoyaltyPointsResponseModel> earnPointsFromOrder({
    required String token,
    required double amount,
    required String orderId,
  });

  /// Earn points from sharing blend
  Future<LoyaltyPointsResponseModel> earnPointsFromShare({
    required String token,
    required String blendId,
  });

  /// Earn points from review
  Future<LoyaltyPointsResponseModel> earnPointsFromReview({
    required String token,
    required String reviewId,
  });

  /// Get loyalty transaction history
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactionHistory({
    required String token,
    required String userId,
  });
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  final ApiRequest apiRequest;

  LoyaltyRemoteDataSourceImpl({required this.apiRequest});

  static const String loyaltyBaseUrl = ApiEndpoints.loyalty;

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
            ? (response.data['history'] as List<dynamic>)
                  .map((json) => LoyaltyTransactionModel.fromJson(json))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to get loyalty history',
              ),
      ApiError() => throw response.failure,
    };
  }
}
