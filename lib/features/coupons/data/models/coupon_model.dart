import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    required super.name,
    required super.description,
    required super.discountType,
    required super.discountValue,
    super.maximumDiscount,
    super.minimumOrderAmount,
    required super.totalUsageLimit,
    required super.usedCount,
    super.userUsageLimit,
    required super.validFrom,
    required super.validUntil,
    required super.applicableTo,
    required super.applicableItems,
    required super.isActive,
    required super.isCurrentlyValid,
    super.discountDisplay,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      discountType: CouponDiscountType.fromString(
        json['discount_type'] ?? 'fixed',
      ),
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      maximumDiscount: json['maximum_discount']?.toDouble(),
      minimumOrderAmount: json['minimum_order_amount']?.toDouble(),
      totalUsageLimit: json['total_usage_limit'] ?? 0,
      usedCount: json['used_count'] ?? 0,
      userUsageLimit: json['user_usage_limit'],
      validFrom: DateTime.parse(
        json['valid_from'] ?? DateTime.now().toIso8601String(),
      ),
      validUntil: DateTime.parse(
        json['valid_until'] ?? DateTime.now().toIso8601String(),
      ),
      applicableTo: CouponApplicableTo.fromString(
        json['applicable_to'] ?? 'all',
      ),
      applicableItems: List<String>.from(json['applicable_items'] ?? []),
      isActive: json['is_active'] ?? false,
      isCurrentlyValid: json['is_currently_valid'] ?? false,
      discountDisplay: json['discount_display'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'name': name,
      'description': description,
      'discount_type': discountType.value,
      'discount_value': discountValue,
      'maximum_discount': maximumDiscount,
      'minimum_order_amount': minimumOrderAmount,
      'total_usage_limit': totalUsageLimit,
      'used_count': usedCount,
      'user_usage_limit': userUsageLimit,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'applicable_to': applicableTo.value,
      'applicable_items': applicableItems,
      'is_active': isActive,
      'is_currently_valid': isCurrentlyValid,
      'discount_display': discountDisplay,
    };
  }

  CouponEntity toEntity() {
    return CouponEntity(
      id: id,
      code: code,
      name: name,
      description: description,
      discountType: discountType,
      discountValue: discountValue,
      maximumDiscount: maximumDiscount,
      minimumOrderAmount: minimumOrderAmount,
      totalUsageLimit: totalUsageLimit,
      usedCount: usedCount,
      userUsageLimit: userUsageLimit,
      validFrom: validFrom,
      validUntil: validUntil,
      applicableTo: applicableTo,
      applicableItems: applicableItems,
      isActive: isActive,
      isCurrentlyValid: isCurrentlyValid,
      discountDisplay: discountDisplay,
    );
  }
}

class CouponValidationModel extends CouponValidationEntity {
  const CouponValidationModel({
    required super.isValid,
    required super.message,
    required super.discountAmount,
    super.coupon,
  });

  factory CouponValidationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CouponValidationModel(
      isValid: json['success'] ?? false,
      message: json['message'] ?? '',
      discountAmount: (data?['discount_amount'] ?? 0).toDouble(),
      coupon: data?['coupon'] != null
          ? CouponModel.fromJson(data!['coupon'])
          : null,
    );
  }

  CouponValidationEntity toEntity() {
    return CouponValidationEntity(
      isValid: isValid,
      message: message,
      discountAmount: discountAmount,
      coupon: coupon,
    );
  }
}
