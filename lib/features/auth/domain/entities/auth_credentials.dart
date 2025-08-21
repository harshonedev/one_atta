import 'package:equatable/equatable.dart';

class AuthCredentials extends Equatable {
  final String email;
  final String password;

  const AuthCredentials({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterCredentials extends Equatable {
  final String email;
  final String password;
  final String? name;

  const RegisterCredentials({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class ForgotPasswordCredentials extends Equatable {
  final String email;

  const ForgotPasswordCredentials({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordCredentials extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordCredentials({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [token, newPassword];
}
