import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:one_atta/features/notifications/data/models/fcm_token_response_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/notifications';

  NotificationRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<FcmTokenResponseModel> updateFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.put,
      url: '$baseUrl/fcm-token',
      token: token,
      data: {'fcmToken': fcmToken},
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? FcmTokenResponseModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to update FCM token',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<FcmTokenResponseModel> removeFcmToken({required String token}) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.delete,
      url: '$baseUrl/fcm-token',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? FcmTokenResponseModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to remove FCM token',
              ),
      ApiError() => throw response.failure,
    };
  }
}
