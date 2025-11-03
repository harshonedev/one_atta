import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/domain/entities/user_profile_entity.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

// Initial State
class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

// Loading States
class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileUpdating extends UserProfileState {
  const UserProfileUpdating();
}

// Success States
class UserProfileLoaded extends UserProfileState {
  final UserProfileEntity profile;

  const UserProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class UserProfileUpdated extends UserProfileState {
  final UserProfileEntity profile;
  final String message;

  const UserProfileUpdated({required this.profile, required this.message});

  @override
  List<Object?> get props => [profile, message];
}

// Error States
class UserProfileError extends UserProfileState {
  final String message;
  final String? errorType;
  final Failure? failure;

  const UserProfileError({required this.message, this.errorType, this.failure});

  @override
  List<Object?> get props => [message, errorType, failure];

  /// Check if error is due to authentication issues
  bool get isAuthError => errorType == 'unauthorized';

  /// Check if error is due to network issues
  bool get isNetworkError => errorType == 'network';

  /// Check if error is due to validation issues
  bool get isValidationError => errorType == 'validation';
}
