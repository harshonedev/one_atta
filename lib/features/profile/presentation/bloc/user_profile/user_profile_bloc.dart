import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/profile/domain/repositories/profile_repository.dart';
import 'package:one_atta/features/profile/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:one_atta/features/profile/presentation/bloc/user_profile/user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final ProfileRepository profileRepository;
  final Logger logger = Logger();

  UserProfileBloc({required this.profileRepository})
    : super(const UserProfileInitial()) {
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<RefreshProfileRequested>(_onRefreshProfileRequested);
    on<ClearProfileCacheRequested>(_onClearProfileCacheRequested);
  }

  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    logger.i('Getting user profile');

    final result = await profileRepository.getUserProfile();
    result.fold(
      (failure) {
        logger.e('Failed to get user profile: ${failure.message}');
        emit(
          UserProfileError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (profile) {
        logger.i('User profile loaded successfully');
        emit(UserProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileUpdating());
    logger.i('Updating user profile');

    final result = await profileRepository.updateProfile(event.profileUpdate);
    result.fold(
      (failure) {
        logger.e('Failed to update profile: ${failure.message}');
        emit(
          UserProfileError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (profile) {
        logger.i('Profile updated successfully');
        emit(
          UserProfileUpdated(
            profile: profile,
            message: 'Profile updated successfully',
          ),
        );
      },
    );
  }

  Future<void> _onRefreshProfileRequested(
    RefreshProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    logger.i('Refreshing user profile (bypassing cache)');

    // Clear cache first to force fresh data
    await profileRepository.clearCachedProfile();

    final result = await profileRepository.getUserProfile();
    result.fold(
      (failure) {
        logger.e('Failed to refresh user profile: ${failure.message}');
        emit(
          UserProfileError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (profile) {
        logger.i('User profile refreshed successfully');
        emit(UserProfileLoaded(profile: profile, isFromCache: false));
      },
    );
  }

  Future<void> _onClearProfileCacheRequested(
    ClearProfileCacheRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    logger.i('Clearing profile cache');

    final result = await profileRepository.clearCachedProfile();
    result.fold(
      (failure) {
        logger.e('Failed to clear profile cache: ${failure.message}');
        emit(
          UserProfileError(
            message: failure.message,
            errorType: _getErrorType(failure),
          ),
        );
      },
      (_) {
        logger.i('Profile cache cleared successfully');
        emit(const UserProfileCacheCleared());
      },
    );
  }

  String _getErrorType(Failure failure) {
    if (failure is UnauthorizedFailure) return 'unauthorized';
    if (failure is NetworkFailure) return 'network';
    if (failure is ValidationFailure) return 'validation';
    if (failure is CacheFailure) return 'cache';
    return 'server';
  }
}
