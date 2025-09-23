import 'package:dio/dio.dart';
import 'package:one_atta/core/constants/api_endpoints.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/models/loyalty_points_response_model.dart';
import 'package:one_atta/features/profile/data/models/loyalty_transaction_model.dart'
    hide LoyaltyPointsResponseModel, RedemptionResponseModel;
import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/data/models/redemption_response_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  static final String baseUrl = ApiEndpoints.auth;
  static final String loyaltyBaseUrl = '${ApiEndpoints.baseUrl}/loyalty';

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileModel> getUserProfile(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to get user profile',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.response?.statusCode == 404) {
        throw ServerFailure('User not found');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to get user profile';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(
    String token,
    ProfileUpdateModel profileUpdate,
  ) async {
    try {
      final response = await dio.put(
        '$baseUrl/profile',
        data: profileUpdate.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to update profile',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationFailure(
          e.response?.data?['errors'] ?? 'Invalid data provided',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to update profile';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<LoyaltyPointsResponseModel> earnPointsFromOrder({
    required String token,
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await dio.post(
        '$loyaltyBaseUrl/earn/order',
        data: {'amount': amount, 'orderId': orderId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoyaltyPointsResponseModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to earn points from order',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to earn points from order';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<LoyaltyPointsResponseModel> earnPointsFromShare({
    required String token,
    required String blendId,
  }) async {
    try {
      final response = await dio.post(
        '$loyaltyBaseUrl/earn/share',
        data: {'blendId': blendId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoyaltyPointsResponseModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to earn points from share',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to earn points from share';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<LoyaltyPointsResponseModel> earnPointsFromReview({
    required String token,
    required String reviewId,
  }) async {
    try {
      final response = await dio.post(
        '$loyaltyBaseUrl/earn/review',
        data: {'reviewId': reviewId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LoyaltyPointsResponseModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to earn points from review',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to earn points from review';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<RedemptionResponseModel> redeemPoints({
    required String token,
    required String orderId,
    required int pointsToRedeem,
  }) async {
    try {
      final response = await dio.post(
        '$loyaltyBaseUrl/redeem',
        data: {'orderId': orderId, 'points': pointsToRedeem},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return RedemptionResponseModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to redeem points',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationFailure(
          e.response?.data?['errors'] ?? 'Invalid data for redemption',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }
      final message = e.response?.data?['message'] ?? 'Failed to redeem points';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<LoyaltyTransactionModel>> getLoyaltyTransactionHistory({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await dio.get(
        '$loyaltyBaseUrl/history/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> transactionsJson = response.data['data'];
        return transactionsJson
            .map((json) => LoyaltyTransactionModel.fromJson(json))
            .toList();
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to get loyalty history',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedFailure('Authentication failed');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }
      final message =
          e.response?.data?['message'] ?? 'Failed to get loyalty history';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
