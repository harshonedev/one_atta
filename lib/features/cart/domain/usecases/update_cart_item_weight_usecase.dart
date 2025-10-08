import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartItemWeightUseCase {
  final CartRepository repository;

  UpdateCartItemWeightUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String productId, int weightInKg) async {
    return await repository.updateItemWeight(productId, weightInKg);
  }
}
