import 'package:equatable/equatable.dart';

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
}
