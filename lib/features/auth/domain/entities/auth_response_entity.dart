import 'package:equatable/equatable.dart';
import 'package:one_atta/features/auth/domain/entities/user_entity.dart';

class AuthResponseEntity extends Equatable {
  final String token;
  final String mobile;
  final String userId;
  final UserEntity user;
  final String message;

  const AuthResponseEntity({
    required this.token,
    required this.mobile,
    required this.userId,
    required this.user,
    required this.message,
  });

  @override
  List<Object> get props => [token, mobile, userId, user, message];
}
