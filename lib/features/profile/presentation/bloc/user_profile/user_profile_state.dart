import 'package:equatable/equatable.dart';
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
  final bool isFromCache;

  const UserProfileLoaded({required this.profile, this.isFromCache = false});

  @override
  List<Object?> get props => [profile, isFromCache];
}

class UserProfileUpdated extends UserProfileState {
  final UserProfileEntity profile;
  final String message;

  const UserProfileUpdated({required this.profile, required this.message});

  @override
  List<Object?> get props => [profile, message];
}

class UserProfileCacheCleared extends UserProfileState {
  const UserProfileCacheCleared();
}

// Error States
class UserProfileError extends UserProfileState {
  final String message;
  final String? errorType;

  const UserProfileError({required this.message, this.errorType});

  @override
  List<Object?> get props => [message, errorType];

  /// Check if error is due to authentication issues
  bool get isAuthError => errorType == 'unauthorized';

  /// Check if error is due to network issues
  bool get isNetworkError => errorType == 'network';

  /// Check if error is due to validation issues
  bool get isValidationError => errorType == 'validation';

  /// Check if error is due to cache issues
  bool get isCacheError => errorType == 'cache';
}
