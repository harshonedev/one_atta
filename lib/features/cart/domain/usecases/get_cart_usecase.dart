import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';
import 'package:one_atta/features/cart/domain/repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<Either<Failure, CartEntity>> call() async {
    return await repository.getCart();
  }
}
