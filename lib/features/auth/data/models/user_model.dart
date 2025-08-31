import 'package:one_atta/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.role,
    required super.loyaltyPoints,
    super.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? 'user',
      loyaltyPoints: json['loyalty_points'] ?? 0,
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'loyalty_points': loyaltyPoints,
      'profile_picture': profilePicture,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      role: role,
      loyaltyPoints: loyaltyPoints,
      profilePicture: profilePicture,
    );
  }
}
