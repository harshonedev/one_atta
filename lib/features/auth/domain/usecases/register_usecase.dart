import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/auth/domain/entities/user.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(RegisterCredentials credentials) async {
    return await repository.register(credentials);
  }
}
