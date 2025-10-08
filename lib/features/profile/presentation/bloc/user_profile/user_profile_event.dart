import 'package:equatable/equatable.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileRequested extends UserProfileEvent {
  const GetUserProfileRequested();

  @override
  List<Object> get props => [];
}

class UpdateProfileRequested extends UserProfileEvent {
  final ProfileUpdateEntity profileUpdate;

  const UpdateProfileRequested({required this.profileUpdate});

  @override
  List<Object?> get props => [profileUpdate];
}

class RefreshProfileRequested extends UserProfileEvent {
  const RefreshProfileRequested();
}
