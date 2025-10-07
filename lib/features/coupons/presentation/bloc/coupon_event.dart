import 'package:equatable/equatable.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => [];
}

/// Apply a coupon to the cart
class ApplyCoupon extends CouponEvent {
  final String couponCode;
  final double orderAmount;
  final List<CouponItem> items;

  const ApplyCoupon({
    required this.couponCode,
    required this.orderAmount,
    required this.items,
  });

  @override
  List<Object?> get props => [couponCode, orderAmount, items];
}

/// Remove applied coupon
class RemoveCoupon extends CouponEvent {
  const RemoveCoupon();
}

/// Revalidate applied coupon when cart changes
class RevalidateCoupon extends CouponEvent {
  final String couponCode;
  final double orderAmount;
  final List<CouponItem> items;

  const RevalidateCoupon({
    required this.couponCode,
    required this.orderAmount,
    required this.items,
  });

  @override
  List<Object?> get props => [couponCode, orderAmount, items];
}
