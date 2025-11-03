import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final Failure? failure;

  const AuthError({required this.message, this.failure});

  @override
  List<Object?> get props => [message, failure];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// OTP specific states
class OtpSent extends AuthState {
  final String message;
  final String? testOtp; // For development/testing

  const OtpSent({required this.message, this.testOtp});

  @override
  List<Object?> get props => [message, testOtp];
}
