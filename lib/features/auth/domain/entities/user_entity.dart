import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final int loyaltyPoints;
  final String? profilePicture;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.loyaltyPoints,
    this.profilePicture,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      role: json['role'] as String,
      loyaltyPoints: json['loyalty_points'] as int,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'loyalty_points': loyaltyPoints,
      'profile_picture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    mobile,
    role,
    loyaltyPoints,
    profilePicture,
  ];
}
