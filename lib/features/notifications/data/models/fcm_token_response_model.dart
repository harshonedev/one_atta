class FcmTokenResponseModel {
  final String message;
  final String? fcmToken;

  FcmTokenResponseModel({required this.message, this.fcmToken});

  factory FcmTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponseModel(
      message: json['message'] as String,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, if (fcmToken != null) 'fcmToken': fcmToken};
  }
}
