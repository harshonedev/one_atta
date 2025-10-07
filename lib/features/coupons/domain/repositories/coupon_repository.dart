import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponRepository {
  /// Apply coupon to calculate final discount
  Future<Either<Failure, CouponValidationEntity>> applyCoupon({
    required String couponCode,
    required double orderAmount,
    required List<CouponItem> items,
  });

  /// Fetch coupon details by coupon code
  Future<Either<Failure, CouponEntity>> fetchCouponByCode({
    required String couponCode,
  });
}
