import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase {
  final CartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String productId, int quantity) async {
    return await repository.updateItemQuantity(productId, quantity);
  }
}
