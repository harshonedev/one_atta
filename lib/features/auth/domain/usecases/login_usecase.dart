import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/domain/entities/user.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(AuthCredentials credentials) async {
    return await repository.login(credentials);
  }
}
