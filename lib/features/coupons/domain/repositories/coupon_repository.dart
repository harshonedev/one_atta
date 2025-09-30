import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponRepository {
  /// Get all available coupons for the user
  Future<Either<Failure, List<CouponEntity>>> getAvailableCoupons({
    double? orderAmount,
    List<String>? itemIds,
  });

  /// Validate a coupon code
  Future<Either<Failure, CouponValidationEntity>> validateCoupon({
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  });

  /// Apply coupon to calculate final discount
  Future<Either<Failure, CouponValidationEntity>> applyCoupon({
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  });

  /// Get coupon details by code
  Future<Either<Failure, CouponEntity>> getCouponByCode(String couponCode);
}
