import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/domain/entities/auth_response_entity.dart';
import 'package:one_atta/features/auth/domain/entities/otp_response_entity.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Login flow
  Future<Either<Failure, OtpResponseEntity>> sendLoginOtp(String mobile);
  Future<Either<Failure, AuthResponseEntity>> verifyLoginOtp(
    String mobile,
    String otp,
  );

  // Registration flow
  Future<Either<Failure, OtpResponseEntity>> sendRegistrationOtp({
    required String mobile,
    required String name,
    required String email,
  });
  Future<Either<Failure, AuthResponseEntity>> verifyRegistrationOtp({
    required String mobile,
    required String otp,
    required String name,
    required String email,
  });

  // Token and user management
  Future<Either<Failure, void>> saveToken(String token);
  Future<Either<Failure, String?>> getToken();
  Future<Either<Failure, void>> removeToken();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
}
