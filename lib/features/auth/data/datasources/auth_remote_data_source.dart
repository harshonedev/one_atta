import 'package:one_atta/features/auth/data/models/auth_response_model.dart';
import 'package:one_atta/features/auth/data/models/otp_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<OtpResponseModel> sendLoginOtp(String mobile);
  Future<AuthResponseModel> verifyLoginOtp(String mobile, String otp);

  Future<OtpResponseModel> sendRegistrationOtp({
    required String mobile,
    required String name,
    required String email,
  });

  Future<AuthResponseModel> verifyRegistrationOtp({
    required String mobile,
    required String otp,
    required String name,
    required String email,
  });
}
