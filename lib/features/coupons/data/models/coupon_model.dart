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
        json['discount_type'] ?? json['discountType'] ?? 'fixed',
      ),
      discountValue: (json['discount_value'] ?? json['discountValue'] ?? 0)
          .toDouble(),
      maximumDiscount: (json['max_discount_amount'] ?? json['maximumDiscount'])
          ?.toDouble(),
      minimumOrderAmount:
          (json['min_order_amount'] ?? json['minimumOrderAmount'])?.toDouble(),
      totalUsageLimit: json['usage_limit'] ?? json['totalUsageLimit'] ?? 0,
      usedCount: json['used_count'] ?? json['usedCount'] ?? 0,
      userUsageLimit: json['usage_limit_per_user'] ?? json['userUsageLimit'],
      validFrom: DateTime.parse(
        json['valid_from'] ??
            json['validFrom'] ??
            DateTime.now().toIso8601String(),
      ),
      validUntil: DateTime.parse(
        json['valid_until'] ??
            json['validUntil'] ??
            DateTime.now().toIso8601String(),
      ),
      applicableTo: CouponApplicableTo.fromString(
        json['applicable_to'] ?? json['applicableTo'] ?? 'all',
      ),
      applicableItems: List<String>.from(
        json['applicable_items'] ?? json['applicableItems'] ?? [],
      ),
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      isCurrentlyValid:
          json['is_currently_valid'] ?? json['isCurrentlyValid'] ?? false,
      discountDisplay: json['discount_display'] ?? json['discountDisplay'],
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
      'max_discount_amount': maximumDiscount,
      'min_order_amount': minimumOrderAmount,
      'usage_limit': totalUsageLimit,
      'used_count': usedCount,
      'usage_limit_per_user': userUsageLimit,
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

  /// Factory for /validate endpoint response (deprecated, use fromApplyResponse)
  factory CouponValidationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    // Handle error response
    if (json['success'] == false) {
      return CouponValidationModel(
        isValid: false,
        message: json['message'] ?? 'Invalid coupon',
        discountAmount: 0.0,
        coupon: null,
      );
    }

    // Success response
    return CouponValidationModel(
      isValid: json['success'] ?? false,
      message: data?['message'] ?? json['message'] ?? '',
      discountAmount: (data?['discount_amount'] ?? 0).toDouble(),
      coupon: data?['coupon'] != null
          ? CouponModel.fromJson(data!['coupon'])
          : null,
    );
  }

  /// Factory for /validate (apply) endpoint response
  factory CouponValidationModel.fromApplyResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    // Handle error response
    if (json['success'] == false) {
      return CouponValidationModel(
        isValid: false,
        message: json['message'] ?? 'Failed to apply coupon',
        discountAmount: 0.0,
        coupon: null,
      );
    }

    // Success response - extract coupon from code if available
    return CouponValidationModel(
      isValid: json['success'] ?? false,
      message: data?['message'] ?? json['message'] ?? '',
      discountAmount: (data?['discount_amount'] ?? 0).toDouble(),
      coupon: null, // Apply endpoint doesn't return full coupon details
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
