import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:one_atta/features/auth/data/models/auth_response_model.dart';
import 'package:one_atta/features/auth/data/models/otp_response_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = ApiEndpoints.auth;

  AuthRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<OtpResponseModel> sendLoginOtp(String mobile) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/login/otp/send',
      data: {'mobile': mobile},
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OtpResponseModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to send login OTP',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<AuthResponseModel> verifyLoginOtp(String mobile, String otp) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/login/otp/verify',
      data: {'mobile': mobile, 'otp': otp},
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AuthResponseModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to verify login OTP',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<OtpResponseModel> sendRegistrationOtp({
    required String mobile,
    required String name,
    required String email,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/register/otp/send',
      data: {'mobile': mobile, 'name': name, 'email': email},
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? OtpResponseModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to send registration OTP',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<AuthResponseModel> verifyRegistrationOtp({
    required String mobile,
    required String otp,
    required String name,
    required String email,
  }) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/register/otp/verify',
      data: {'mobile': mobile, 'otp': otp, 'name': name, 'email': email},
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? AuthResponseModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to verify registration OTP',
              ),
      ApiError() => throw response.failure,
    };
  }
}
