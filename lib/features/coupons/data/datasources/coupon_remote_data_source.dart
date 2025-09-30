import 'package:one_atta/features/coupons/data/models/coupon_model.dart';

abstract class CouponRemoteDataSource {
  /// Get available coupons from API
  Future<List<CouponModel>> getAvailableCoupons({
    required String token,
    double? orderAmount,
    List<String>? itemIds,
  });

  /// Validate coupon code
  Future<CouponValidationModel> validateCoupon({
    required String token,
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  });

  /// Apply coupon to get final discount
  Future<CouponValidationModel> applyCoupon({
    required String token,
    required String couponCode,
    required double orderAmount,
    required List<String> itemIds,
  });

  /// Get coupon by code
  Future<CouponModel> getCouponByCode({
    required String token,
    required String couponCode,
  });
}
