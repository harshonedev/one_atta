import 'package:equatable/equatable.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final bool isVerified;
  final bool isProfileComplete;
  final String role;
  final int loyaltyPoints;
  final String? profilePicture;
  final List<String> likedRecipes;
  final List<AddressEntity> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.isVerified,
    required this.isProfileComplete,
    required this.role,
    required this.loyaltyPoints,
    this.profilePicture,
    required this.likedRecipes,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    mobile,
    isVerified,
    isProfileComplete,
    role,
    loyaltyPoints,
    profilePicture,
    likedRecipes,
    addresses,
    createdAt,
    updatedAt,
  ];
}

class ProfileUpdateEntity extends Equatable {
  final String? name;
  final String? email;
  final String? mobile;
  final String? profilePicture;

  const ProfileUpdateEntity({
    this.name,
    this.email,
    this.mobile,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [name, email, mobile, profilePicture];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (mobile != null) map['mobile'] = mobile;
    if (profilePicture != null) map['profile_picture'] = profilePicture;
    return map;
  }
}
