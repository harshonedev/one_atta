import 'package:one_atta/features/address/data/models/address_model.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.isVerified,
    required super.isProfileComplete,
    required super.role,
    required super.loyaltyPoints,
    super.profilePicture,
    required super.likedRecipes,
    required super.addresses,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isProfileComplete: json['isProfileComplete'] ?? false,
      role: json['role'] ?? 'user',
      loyaltyPoints: json['loyalty_points'] ?? 0,
      profilePicture: json['profile_picture'],
      likedRecipes: List<String>.from(json['liked_recipes'] ?? []),
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map((address) => AddressModel.fromJson(address))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      mobile: entity.mobile,
      isVerified: entity.isVerified,
      isProfileComplete: entity.isProfileComplete,
      role: entity.role,
      loyaltyPoints: entity.loyaltyPoints,
      profilePicture: entity.profilePicture,
      likedRecipes: entity.likedRecipes,
      addresses: entity.addresses,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
      'role': role,
      'loyalty_points': loyaltyPoints,
      'profile_picture': profilePicture,
      'liked_recipes': likedRecipes,
      'addresses': addresses
          .map((address) => (address as AddressModel).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      isVerified: isVerified,
      isProfileComplete: isProfileComplete,
      role: role,
      loyaltyPoints: loyaltyPoints,
      profilePicture: profilePicture,
      likedRecipes: likedRecipes,
      addresses: addresses,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ProfileResponseModel {
  final bool success;
  final String message;
  final UserProfileModel user;

  const ProfileResponseModel({
    required this.success,
    required this.message,
    required this.user,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: UserProfileModel.fromJson(json['data']['user'] ?? {}),
    );
  }
}
