import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';
import 'package:one_atta/features/coupons/domain/repositories/coupon_repository.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_event.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository couponRepository;
  final Logger logger = Logger();

  CouponBloc({required this.couponRepository}) : super(const CouponInitial()) {
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<RevalidateCoupon>(_onRevalidateCoupon);
  }

  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CouponState> emit,
  ) async {
    emit(const CouponLoading('Applying coupon'));
    logger.i('Applying coupon: ${event.couponCode}');

    final result = await couponRepository.fetchCouponByCode(
      couponCode: event.couponCode,
    );

    result.fold(
      (failure) {
        logger.e(
          'Failed to fetch coupon ${event.couponCode}: ${failure.message}',
        );
        emit(
          CouponError(
            message: failure.message,
            operation: 'apply',
            failure: failure,
          ),
        );
      },
      (coupon) {
        logger.i('Coupon fetched: $coupon');

        // Validate the coupon against the current order
        final validation = _validateCoupon(
          coupon: coupon,
          orderAmount: event.orderAmount,
          items: event.items,
        );

        if (validation.isValid) {
          logger.i(
            'Coupon ${event.couponCode} applied successfully: discount ₹${validation.discountAmount}',
          );
          emit(CouponApplied(application: validation, appliedCoupon: coupon));
        } else {
          logger.w('Coupon validation failed: ${validation.message}');
          emit(CouponError(message: validation.message, operation: 'apply'));
        }
      },
    );
  }

  Future<void> _onRemoveCoupon(
    RemoveCoupon event,
    Emitter<CouponState> emit,
  ) async {
    logger.i('Removing applied coupon');
    emit(const CouponRemoved());
  }

  Future<void> _onRevalidateCoupon(
    RevalidateCoupon event,
    Emitter<CouponState> emit,
  ) async {
    // Silently revalidate without showing loading state
    logger.i('Revalidating coupon: ${event.couponCode}');

    final result = await couponRepository.fetchCouponByCode(
      couponCode: event.couponCode,
    );

    result.fold(
      (failure) {
        logger.e(
          'Failed to revalidate coupon ${event.couponCode}: ${failure.message}',
        );
        // If fetch fails, remove the coupon
        emit(const CouponRemoved());
      },
      (coupon) {
        // Validate the coupon against the updated order
        final validation = _validateCoupon(
          coupon: coupon,
          orderAmount: event.orderAmount,
          items: event.items,
        );

        if (validation.isValid) {
          logger.i(
            'Coupon ${event.couponCode} revalidated: discount ₹${validation.discountAmount}',
          );
          emit(CouponApplied(application: validation, appliedCoupon: coupon));
        } else {
          // If validation fails, remove the coupon
          logger.w('Coupon revalidation failed: ${validation.message}');
          emit(const CouponRemoved());
        }
      },
    );
  }

  /// Validate coupon against order details and calculate discount
  CouponValidationEntity _validateCoupon({
    required CouponEntity coupon,
    required double orderAmount,
    required List<CouponItem> items,
  }) {
    // 1. Check if coupon is active
    if (!coupon.isActive) {
      return const CouponValidationEntity(
        isValid: false,
        message: 'This coupon is currently inactive',
        discountAmount: 0.0,
      );
    }

    // 2. Check if coupon is currently valid (date range)
    final now = DateTime.now();
    if (now.isBefore(coupon.validFrom)) {
      return CouponValidationEntity(
        isValid: false,
        message:
            'This coupon will be valid from ${_formatDate(coupon.validFrom)}',
        discountAmount: 0.0,
      );
    }

    if (now.isAfter(coupon.validUntil)) {
      return CouponValidationEntity(
        isValid: false,
        message: 'This coupon expired on ${_formatDate(coupon.validUntil)}',
        discountAmount: 0.0,
      );
    }

    // 3. Check minimum order amount
    if (coupon.minimumOrderAmount != null &&
        orderAmount < coupon.minimumOrderAmount!) {
      return CouponValidationEntity(
        isValid: false,
        message:
            'Minimum order amount of ₹${coupon.minimumOrderAmount!.toInt()} required',
        discountAmount: 0.0,
      );
    }

    // 4. Check usage limits
    if (coupon.usedCount >= coupon.totalUsageLimit) {
      return const CouponValidationEntity(
        isValid: false,
        message: 'This coupon has reached its usage limit',
        discountAmount: 0.0,
      );
    }

    // 5. Check applicable items
    final validationResult = _validateApplicableItems(
      coupon: coupon,
      items: items,
    );

    if (!validationResult.isValid) {
      return validationResult;
    }

    // 6. Calculate applicable amount (only for valid items)
    final applicableAmount = _calculateApplicableAmount(
      coupon: coupon,
      items: items,
      totalAmount: orderAmount,
    );

    // 7. Calculate discount amount
    final discountAmount = _calculateDiscount(
      coupon: coupon,
      applicableAmount: applicableAmount,
    );

    if (discountAmount <= 0) {
      return const CouponValidationEntity(
        isValid: false,
        message: 'No discount applicable for this order',
        discountAmount: 0.0,
      );
    }

    // Success! Coupon is valid
    return CouponValidationEntity(
      isValid: true,
      message:
          'Coupon applied successfully! You saved ₹${discountAmount.toInt()}',
      discountAmount: discountAmount,
      coupon: coupon,
    );
  }

  /// Validate if coupon is applicable to cart items
  CouponValidationEntity _validateApplicableItems({
    required CouponEntity coupon,
    required List<CouponItem> items,
  }) {
    switch (coupon.applicableTo) {
      case CouponApplicableTo.all:
        // Applicable to all items
        return const CouponValidationEntity(
          isValid: true,
          message: 'Valid',
          discountAmount: 0.0,
        );

      case CouponApplicableTo.products:
        // Check if there are any products in the cart
        final hasProducts = items.any(
          (item) => item.itemType.toLowerCase() == 'product',
        );
        if (!hasProducts) {
          return const CouponValidationEntity(
            isValid: false,
            message: 'This coupon is only applicable to products',
            discountAmount: 0.0,
          );
        }
        return const CouponValidationEntity(
          isValid: true,
          message: 'Valid',
          discountAmount: 0.0,
        );

      case CouponApplicableTo.blends:
        // Check if there are any blends in the cart
        final hasBlends = items.any(
          (item) => item.itemType.toLowerCase() == 'blend',
        );
        if (!hasBlends) {
          return const CouponValidationEntity(
            isValid: false,
            message: 'This coupon is only applicable to blends',
            discountAmount: 0.0,
          );
        }
        return const CouponValidationEntity(
          isValid: true,
          message: 'Valid',
          discountAmount: 0.0,
        );

      case CouponApplicableTo.specificItems:
        // Check if any cart items match the applicable items
        final hasMatchingItems = items.any(
          (item) => coupon.applicableItems.contains(item.itemId),
        );
        if (!hasMatchingItems) {
          return const CouponValidationEntity(
            isValid: false,
            message: 'This coupon is not applicable to items in your cart',
            discountAmount: 0.0,
          );
        }
        return const CouponValidationEntity(
          isValid: true,
          message: 'Valid',
          discountAmount: 0.0,
        );
    }
  }

  /// Calculate the amount on which discount should be applied
  double _calculateApplicableAmount({
    required CouponEntity coupon,
    required List<CouponItem> items,
    required double totalAmount,
  }) {
    switch (coupon.applicableTo) {
      case CouponApplicableTo.all:
        return totalAmount;

      case CouponApplicableTo.products:
        return items
            .where((item) => item.itemType.toLowerCase() == 'product')
            .fold(0.0, (sum, item) => sum + item.totalPrice);

      case CouponApplicableTo.blends:
        return items
            .where((item) => item.itemType.toLowerCase() == 'blend')
            .fold(0.0, (sum, item) => sum + item.totalPrice);

      case CouponApplicableTo.specificItems:
        return items
            .where((item) => coupon.applicableItems.contains(item.itemId))
            .fold(0.0, (sum, item) => sum + item.totalPrice);
    }
  }

  /// Calculate discount based on coupon type
  double _calculateDiscount({
    required CouponEntity coupon,
    required double applicableAmount,
  }) {
    switch (coupon.discountType) {
      case CouponDiscountType.fixed:
        // Fixed discount - return the discount value directly
        // But don't exceed the applicable amount
        return applicableAmount >= coupon.discountValue
            ? coupon.discountValue
            : applicableAmount;

      case CouponDiscountType.percentage:
        // Percentage discount
        final percentageDiscount =
            (applicableAmount * coupon.discountValue) / 100;

        // Apply maximum discount cap if specified
        if (coupon.maximumDiscount != null &&
            percentageDiscount > coupon.maximumDiscount!) {
          return coupon.maximumDiscount!;
        }

        return percentageDiscount;
    }
  }

  /// Helper to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
