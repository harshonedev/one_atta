import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/refunds/domain/entities/refund_entity.dart';

abstract class RefundRepository {
  Future<Either<Failure, RefundEntity?>> getRefundByOrderId(String orderId);
}
