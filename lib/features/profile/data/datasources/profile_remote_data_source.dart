import 'package:one_atta/features/profile/data/models/profile_update_model.dart';
import 'package:one_atta/features/profile/data/models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  /// Get user profile from the API
  Future<UserProfileModel> getUserProfile(String token);

  /// Update user profile
  Future<UserProfileModel> updateProfile(
    String token,
    ProfileUpdateModel profileUpdate,
  );
}
