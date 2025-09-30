import 'package:equatable/equatable.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CouponInitial extends CouponState {
  const CouponInitial();
}

/// Loading states
class CouponLoading extends CouponState {
  final String operation;

  const CouponLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// Success states
class AvailableCouponsLoaded extends CouponState {
  final List<CouponEntity> coupons;

  const AvailableCouponsLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class CouponValidated extends CouponState {
  final CouponValidationEntity validation;

  const CouponValidated(this.validation);

  @override
  List<Object?> get props => [validation];
}

class CouponApplied extends CouponState {
  final CouponValidationEntity application;
  final CouponEntity appliedCoupon;

  const CouponApplied({required this.application, required this.appliedCoupon});

  @override
  List<Object?> get props => [application, appliedCoupon];

  /// Get user-friendly success message
  String get successMessage =>
      'Coupon applied! You saved ₹${application.discountAmount.toInt()}';
}

class CouponRemoved extends CouponState {
  const CouponRemoved();
}

class CouponDetailsLoaded extends CouponState {
  final CouponEntity coupon;

  const CouponDetailsLoaded(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

/// Error states
class CouponError extends CouponState {
  final String message;
  final String operation;

  const CouponError({required this.message, required this.operation});

  @override
  List<Object?> get props => [message, operation];

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (operation) {
      case 'validate':
        return 'Invalid coupon code. Please check and try again.';
      case 'apply':
        return 'Unable to apply coupon. $message';
      case 'load_available':
        return 'Unable to load available coupons.';
      case 'get_details':
        return 'Coupon not found.';
      default:
        return message;
    }
  }
}
