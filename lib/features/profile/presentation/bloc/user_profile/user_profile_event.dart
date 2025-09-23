import 'package:equatable/equatable.dart';
import 'package:one_atta/features/profile/domain/entities/profile_update_entity.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileRequested extends UserProfileEvent {
  final bool forceRefresh;
  const GetUserProfileRequested({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
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

class ClearProfileCacheRequested extends UserProfileEvent {
  const ClearProfileCacheRequested();
}
