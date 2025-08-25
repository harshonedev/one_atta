import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;

  const AuthLoginRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthRegisterRequested extends AuthEvent {

  const AuthRegisterRequested();

  @override
  List<Object> get props => [];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {

  const AuthForgotPasswordRequested();

  @override
  List<Object> get props => [];
}

class AuthResetPasswordRequested extends AuthEvent {


  const AuthResetPasswordRequested();

  @override
  List<Object> get props => [];
}
