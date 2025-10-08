import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';

class ProfileUpdateModel extends ProfileUpdateEntity {
  const ProfileUpdateModel({
    super.name,
    super.email,
    super.mobile,
    super.profilePicture,
  });

  factory ProfileUpdateModel.fromEntity(ProfileUpdateEntity entity) {
    return ProfileUpdateModel(
      name: entity.name,
      email: entity.email,
      mobile: entity.mobile,
      profilePicture: entity.profilePicture,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) {
      map['name'] = name;
    }
    if (email != null) {
      map['email'] = email;
    }
    if (mobile != null) {
      map['mobile'] = mobile;
    }
    if (profilePicture != null) {
      map['profile_picture'] = profilePicture;
    }
    return map;
  }
}
