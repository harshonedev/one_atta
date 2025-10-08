import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart'
   ;

abstract class ProfileRepository {
  /// Get the current user's complete profile information
  /// Returns user profile with personal details, addresses, and loyalty points
  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  /// Update user profile information
  /// Only updates the fields that are provided in the ProfileUpdateEntity
  /// Automatically filters out protected fields
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    ProfileUpdateEntity profileUpdate,
  );

}