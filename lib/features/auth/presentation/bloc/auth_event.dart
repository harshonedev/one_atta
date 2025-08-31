import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

// Login OTP Events
class SendLoginOtpRequested extends AuthEvent {
  final String mobile;

  const SendLoginOtpRequested({required this.mobile});

  @override
  List<Object> get props => [mobile];
}

class VerifyLoginOtpRequested extends AuthEvent {
  final String mobile;
  final String otp;

  const VerifyLoginOtpRequested({required this.mobile, required this.otp});

  @override
  List<Object> get props => [mobile, otp];
}

// Registration OTP Events
class SendRegistrationOtpRequested extends AuthEvent {
  final String mobile;
  final String name;
  final String email;

  const SendRegistrationOtpRequested({
    required this.mobile,
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [mobile, name, email];
}

class VerifyRegistrationOtpRequested extends AuthEvent {
  final String mobile;
  final String otp;
  final String name;
  final String email;

  const VerifyRegistrationOtpRequested({
    required this.mobile,
    required this.otp,
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [mobile, otp, name, email];
}

class AuthLogoutRequested extends AuthEvent {}
