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
