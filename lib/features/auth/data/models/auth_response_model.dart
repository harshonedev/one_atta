import 'package:one_atta/features/auth/data/models/user_model.dart';
import 'package:one_atta/features/auth/domain/entities/auth_response_entity.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.token,
    required super.mobile,
    required super.userId,
    required super.user,
    required super.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      mobile: json['mobile'] ?? '',
      userId: json['userId'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'mobile': mobile,
      'userId': userId,
      'user': (user as UserModel).toJson(),
      'message': message,
    };
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      token: token,
      mobile: mobile,
      userId: userId,
      user: (user as UserModel).toEntity(),
      message: message,
    );
  }
}
