import 'package:one_atta/features/auth/domain/entities/otp_response_entity.dart';

class OtpResponseModel extends OtpResponseEntity {
  const OtpResponseModel({
    required super.requestId,
    required super.message,
    super.testOtp,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      requestId: json['requestId'] ?? '',
      message: json['message'] ?? '',
      testOtp: json['testOtp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'message': message,
      if (testOtp != null) 'testOtp': testOtp,
    };
  }

  OtpResponseEntity toEntity() {
    return OtpResponseEntity(
      requestId: requestId,
      message: message,
      testOtp: testOtp,
    );
  }
}
