import 'package:equatable/equatable.dart';

class ProfileUpdateEntity extends Equatable {
  final String? fullName;
  final String? email;

  const ProfileUpdateEntity({this.fullName, this.email});

  @override
  List<Object?> get props => [fullName, email];
}
