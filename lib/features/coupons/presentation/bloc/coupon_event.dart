import 'package:equatable/equatable.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => [];
}

/// Load available coupons for the user
class LoadAvailableCoupons extends CouponEvent {
  final double? orderAmount;
  final List<String>? itemIds;

  const LoadAvailableCoupons({this.orderAmount, this.itemIds});

  @override
  List<Object?> get props => [orderAmount, itemIds];
}

/// Validate a coupon code
class ValidateCoupon extends CouponEvent {
  final String couponCode;
  final double orderAmount;
  final List<String> itemIds;

  const ValidateCoupon({
    required this.couponCode,
    required this.orderAmount,
    required this.itemIds,
  });

  @override
  List<Object?> get props => [couponCode, orderAmount, itemIds];
}

/// Apply a coupon to the cart
class ApplyCoupon extends CouponEvent {
  final String couponCode;
  final double orderAmount;
  final List<String> itemIds;

  const ApplyCoupon({
    required this.couponCode,
    required this.orderAmount,
    required this.itemIds,
  });

  @override
  List<Object?> get props => [couponCode, orderAmount, itemIds];
}

/// Remove applied coupon
class RemoveCoupon extends CouponEvent {
  const RemoveCoupon();
}

/// Reset coupon state
class ResetCouponState extends CouponEvent {
  const ResetCouponState();
}

/// Get coupon by code
class GetCouponByCode extends CouponEvent {
  final String couponCode;

  const GetCouponByCode(this.couponCode);

  @override
  List<Object?> get props => [couponCode];
}
