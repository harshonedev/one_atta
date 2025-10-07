import 'package:one_atta/features/coupons/data/models/coupon_model.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponRemoteDataSource {
  /// Apply coupon to get final discount
  Future<CouponValidationModel> applyCoupon({
    required String token,
    required String couponCode,
    required double orderAmount,
    required List<CouponItem> items,
  });

  /// Fetch coupon details by coupon code
  Future<CouponModel> fetchCouponByCode({
    required String token,
    required String couponCode,
  });
}
