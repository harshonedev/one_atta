import 'package:equatable/equatable.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final AuthCredentials credentials;

  const AuthLoginRequested({required this.credentials});

  @override
  List<Object> get props => [credentials];
}

class AuthRegisterRequested extends AuthEvent {
  final RegisterCredentials credentials;

  const AuthRegisterRequested({required this.credentials});

  @override
  List<Object> get props => [credentials];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final ForgotPasswordCredentials credentials;

  const AuthForgotPasswordRequested({required this.credentials});

  @override
  List<Object> get props => [credentials];
}

class AuthResetPasswordRequested extends AuthEvent {
  final ResetPasswordCredentials credentials;

  const AuthResetPasswordRequested({required this.credentials});

  @override
  List<Object> get props => [credentials];
}
