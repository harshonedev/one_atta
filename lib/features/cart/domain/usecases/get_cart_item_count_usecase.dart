import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/cart/domain/repositories/cart_repository.dart';

class GetCartItemCountUseCase {
  final CartRepository repository;

  GetCartItemCountUseCase(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getCartItemCount();
  }
}
