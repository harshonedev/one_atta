import 'package:equatable/equatable.dart';

/// Entity representing a coupon in the app
class CouponEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final CouponDiscountType discountType;
  final double discountValue;
  final double? maximumDiscount;
  final double? minimumOrderAmount;
  final int totalUsageLimit;
  final int usedCount;
  final int? userUsageLimit;
  final DateTime validFrom;
  final DateTime validUntil;
  final CouponApplicableTo applicableTo;
  final List<String> applicableItems;
  final bool isActive;
  final bool isCurrentlyValid;
  final String? discountDisplay;

  const CouponEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maximumDiscount,
    this.minimumOrderAmount,
    required this.totalUsageLimit,
    required this.usedCount,
    this.userUsageLimit,
    required this.validFrom,
    required this.validUntil,
    required this.applicableTo,
    required this.applicableItems,
    required this.isActive,
    required this.isCurrentlyValid,
    this.discountDisplay,
  });

  /// Get the discount amount for a given order total
  double getDiscountAmount(double orderTotal) {
    if (!isCurrentlyValid || !isActive) return 0.0;

    if (minimumOrderAmount != null && orderTotal < minimumOrderAmount!) {
      return 0.0;
    }

    switch (discountType) {
      case CouponDiscountType.fixed:
        return discountValue;
      case CouponDiscountType.percentage:
        final percentageDiscount = (orderTotal * discountValue) / 100;
        if (maximumDiscount != null) {
          return percentageDiscount > maximumDiscount!
              ? maximumDiscount!
              : percentageDiscount;
        }
        return percentageDiscount;
    }
  }

  /// Check if coupon can be applied to order
  bool canApplyToOrder(double orderTotal, List<String> itemIds) {
    if (!isCurrentlyValid || !isActive) return false;

    if (minimumOrderAmount != null && orderTotal < minimumOrderAmount!) {
      return false;
    }

    if (usedCount >= totalUsageLimit) return false;

    // Check item applicability
    if (applicableTo == CouponApplicableTo.specificItems) {
      return itemIds.any((id) => applicableItems.contains(id));
    }

    return true;
  }

  /// Get formatted discount display text
  String get formattedDiscountDisplay {
    if (discountDisplay != null) return discountDisplay!;

    switch (discountType) {
      case CouponDiscountType.fixed:
        return '₹${discountValue.toInt()} OFF';
      case CouponDiscountType.percentage:
        if (maximumDiscount != null) {
          return '${discountValue.toInt()}% OFF up to ₹${maximumDiscount!.toInt()}';
        }
        return '${discountValue.toInt()}% OFF';
    }
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    discountType,
    discountValue,
    maximumDiscount,
    minimumOrderAmount,
    totalUsageLimit,
    usedCount,
    userUsageLimit,
    validFrom,
    validUntil,
    applicableTo,
    applicableItems,
    isActive,
    isCurrentlyValid,
    discountDisplay,
  ];
}

/// Entity for coupon validation response
class CouponValidationEntity extends Equatable {
  final bool isValid;
  final String message;
  final double discountAmount;
  final CouponEntity? coupon;

  const CouponValidationEntity({
    required this.isValid,
    required this.message,
    required this.discountAmount,
    this.coupon,
  });

  @override
  List<Object?> get props => [isValid, message, discountAmount, coupon];
}

/// Enum for coupon discount types
enum CouponDiscountType {
  fixed('fixed'),
  percentage('percentage');

  const CouponDiscountType(this.value);
  final String value;

  static CouponDiscountType fromString(String value) {
    return CouponDiscountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CouponDiscountType.fixed,
    );
  }
}

/// Enum for coupon applicable items
enum CouponApplicableTo {
  all('all'),
  products('products'),
  blends('blends'),
  specificItems('specific_items');

  const CouponApplicableTo(this.value);
  final String value;

  static CouponApplicableTo fromString(String value) {
    return CouponApplicableTo.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CouponApplicableTo.all,
    );
  }
}


class CouponItem extends Equatable {
  final String itemId; //item id
  final String itemType;
  final int quantity;
  final double pricePerKg;
  final double totalPrice;

  const CouponItem({
    required this.itemId,
    required this.itemType,
    required this.quantity,
    required this.pricePerKg,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
    itemId,
    itemType,
    quantity,
    pricePerKg,
    totalPrice,
  ];
}

