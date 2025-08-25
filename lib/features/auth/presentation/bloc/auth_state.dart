import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({required this.message});

  @override
  List<Object> get props => [message];
}


class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? email;

  const User({
    required this.id,
    required this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [id, phoneNumber, email];
}
