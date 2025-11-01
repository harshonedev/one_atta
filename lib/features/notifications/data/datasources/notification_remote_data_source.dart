import 'package:one_atta/features/notifications/data/models/fcm_token_response_model.dart';

abstract class NotificationRemoteDataSource {
  Future<FcmTokenResponseModel> updateFcmToken({
    required String token,
    required String fcmToken,
  });

  Future<FcmTokenResponseModel> removeFcmToken({required String token});
}
