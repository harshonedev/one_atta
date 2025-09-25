import 'package:one_atta/features/profile/domain/entities/profile_update_entity.dart';

class ProfileUpdateModel extends ProfileUpdateEntity {
  const ProfileUpdateModel({super.fullName, super.email});

  factory ProfileUpdateModel.fromEntity(ProfileUpdateEntity entity) {
    return ProfileUpdateModel(fullName: entity.fullName, email: entity.email);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) {
      map['name'] = fullName;
    }
    if (email != null) {
      map['email'] = email;
    }
    return map;
  }
}
