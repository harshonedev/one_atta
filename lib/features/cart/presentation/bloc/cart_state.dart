import 'package:equatable/equatable.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;
  final AddressEntity? selectedAddress;
  final int itemCount;
  final double mrpTotal; // Total MRP value
  final double itemTotal; // Actual item total (with any product discounts)
  final double? deliveryFee; // Delivery fee
  final DeliveryInfo? deliveryInfo;
  final double couponDiscount; // Discount from coupons
  final double loyaltyDiscount; // Discount from loyalty points
  final double savingsTotal; // Total savings amount
  final double toPayTotal; // Final amount to pay
  final bool isDiscountApplied;
  final DiscountType? discountType;
  final CouponEntity? appliedCoupon;
  final int loyaltyPointsRedeemed; // Track redeemed loyalty points

  const CartLoaded({
    required this.cart,
    required this.itemCount,
    this.selectedAddress,
    this.mrpTotal = 0.0,
    this.itemTotal = 0.0,
    this.deliveryFee,
    this.deliveryInfo,
    this.couponDiscount = 0.0,
    this.loyaltyDiscount = 0.0,
    this.savingsTotal = 0.0,
    this.toPayTotal = 0.0,
    this.isDiscountApplied = false,
    this.discountType,
    this.appliedCoupon,
    this.loyaltyPointsRedeemed = 0,
  });
  @override
  List<Object?> get props => [
    cart,
    itemCount,
    mrpTotal,
    itemTotal,
    deliveryFee,
    couponDiscount,
    loyaltyDiscount,
    savingsTotal,
    toPayTotal,
    selectedAddress,
    isDiscountApplied,
    discountType,
    appliedCoupon,
    loyaltyPointsRedeemed,
    deliveryInfo,
  ];

  CartLoaded copyWith({
    CartEntity? cart,
    int? itemCount,
    double? mrpTotal,
    double? itemTotal,
    double? deliveryFee,
    double? couponDiscount,
    double? loyaltyDiscount,
    double? savingsTotal,
    double? toPayTotal,
    AddressEntity? selectedAddress,
    bool? clearSelectedAddress,
    bool? isDiscountApplied,
    DiscountType? discountType,
    CouponEntity? appliedCoupon,
    bool? clearAppliedCoupon,
    int? loyaltyPointsRedeemed,
    DeliveryInfo? deliveryInfo,
  }) {
    return CartLoaded(
      cart: cart ?? this.cart,
      itemCount: itemCount ?? this.itemCount,
      mrpTotal: mrpTotal ?? this.mrpTotal,
      itemTotal: itemTotal ?? this.itemTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      loyaltyDiscount: loyaltyDiscount ?? this.loyaltyDiscount,
      savingsTotal: savingsTotal ?? this.savingsTotal,
      toPayTotal: toPayTotal ?? this.toPayTotal,
      selectedAddress: clearSelectedAddress == true
          ? null
          : (selectedAddress ?? this.selectedAddress),
      isDiscountApplied: isDiscountApplied ?? this.isDiscountApplied,
      discountType: discountType ?? this.discountType,
      appliedCoupon: clearAppliedCoupon == true
          ? null
          : (appliedCoupon ?? this.appliedCoupon),
      loyaltyPointsRedeemed:
          loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
    );
  }
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}

class CartCleared extends CartState {
  final String message;

  const CartCleared({required this.message});

  @override
  List<Object> get props => [message];
}

class DeliveryInfo extends Equatable {
  final double deliveryFee;
  final bool isDeliveryFree;
  final double deliveryThreshold;

  const DeliveryInfo({
    required this.deliveryFee,
    required this.isDeliveryFree,
    required this.deliveryThreshold,
  });

  @override
  List<Object?> get props => [deliveryFee, isDeliveryFree, deliveryThreshold];
}

enum DiscountType { coupon, loyalty }
