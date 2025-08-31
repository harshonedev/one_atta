import 'package:dio/dio.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:one_atta/features/auth/data/models/auth_response_model.dart';
import 'package:one_atta/features/auth/data/models/otp_response_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'http://localhost:5000/api/app/auth';

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<OtpResponseModel> sendLoginOtp(String mobile) async {
    try {
      final response = await dio.post(
        '$baseUrl/login/otp/send',
        data: {'mobile': mobile},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return OtpResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to send login OTP',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to send login OTP';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponseModel> verifyLoginOtp(String mobile, String otp) async {
    try {
      final response = await dio.post(
        '$baseUrl/login/otp/verify',
        data: {'mobile': mobile, 'otp': otp},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to verify login OTP',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to verify login OTP';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<OtpResponseModel> sendRegistrationOtp({
    required String mobile,
    required String name,
    required String email,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/register/otp/send',
        data: {'mobile': mobile, 'name': name, 'email': email},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return OtpResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to send registration OTP',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to send registration OTP';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponseModel> verifyRegistrationOtp({
    required String mobile,
    required String otp,
    required String name,
    required String email,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/register/otp/verify',
        data: {'mobile': mobile, 'otp': otp, 'name': name, 'email': email},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to verify registration OTP',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message =
          e.response?.data?['message'] ?? 'Failed to verify registration OTP';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}
