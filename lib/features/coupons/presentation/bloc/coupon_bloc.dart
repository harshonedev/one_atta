import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/coupons/domain/repositories/coupon_repository.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_event.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository couponRepository;
  final Logger logger = Logger();

  CouponBloc({required this.couponRepository}) : super(const CouponInitial()) {
    on<LoadAvailableCoupons>(_onLoadAvailableCoupons);
    on<ValidateCoupon>(_onValidateCoupon);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<ResetCouponState>(_onResetCouponState);
    on<GetCouponByCode>(_onGetCouponByCode);
  }

  Future<void> _onLoadAvailableCoupons(
    LoadAvailableCoupons event,
    Emitter<CouponState> emit,
  ) async {
    emit(const CouponLoading('Loading available coupons'));
    logger.i('Loading available coupons for order: ${event.orderAmount}');

    final result = await couponRepository.getAvailableCoupons(
      orderAmount: event.orderAmount,
      itemIds: event.itemIds,
    );

    result.fold(
      (failure) {
        logger.e('Failed to load available coupons: ${failure.message}');
        emit(
          CouponError(message: failure.message, operation: 'load_available'),
        );
      },
      (coupons) {
        logger.i('Loaded ${coupons.length} available coupons');
        emit(AvailableCouponsLoaded(coupons));
      },
    );
  }

  Future<void> _onValidateCoupon(
    ValidateCoupon event,
    Emitter<CouponState> emit,
  ) async {
    emit(const CouponLoading('Validating coupon'));
    logger.i('Validating coupon: ${event.couponCode}');

    final result = await couponRepository.validateCoupon(
      couponCode: event.couponCode,
      orderAmount: event.orderAmount,
      itemIds: event.itemIds,
    );

    result.fold(
      (failure) {
        logger.e(
          'Failed to validate coupon ${event.couponCode}: ${failure.message}',
        );
        emit(CouponError(message: failure.message, operation: 'validate'));
      },
      (validation) {
        logger.i('Coupon validation result: ${validation.isValid}');
        emit(CouponValidated(validation));
      },
    );
  }

  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CouponState> emit,
  ) async {
    emit(const CouponLoading('Applying coupon'));
    logger.i('Applying coupon: ${event.couponCode}');

    final result = await couponRepository.applyCoupon(
      couponCode: event.couponCode,
      orderAmount: event.orderAmount,
      itemIds: event.itemIds,
    );

    result.fold(
      (failure) {
        logger.e(
          'Failed to apply coupon ${event.couponCode}: ${failure.message}',
        );
        emit(CouponError(message: failure.message, operation: 'apply'));
      },
      (application) {
        if (application.isValid && application.coupon != null) {
          logger.i(
            'Coupon applied successfully: ${application.discountAmount}',
          );
          emit(
            CouponApplied(
              application: application,
              appliedCoupon: application.coupon!,
            ),
          );
        } else {
          logger.w('Coupon application failed: ${application.message}');
          emit(CouponError(message: application.message, operation: 'apply'));
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

  Future<void> _onResetCouponState(
    ResetCouponState event,
    Emitter<CouponState> emit,
  ) async {
    logger.i('Resetting coupon state');
    emit(const CouponInitial());
  }

  Future<void> _onGetCouponByCode(
    GetCouponByCode event,
    Emitter<CouponState> emit,
  ) async {
    emit(const CouponLoading('Loading coupon details'));
    logger.i('Getting coupon details for: ${event.couponCode}');

    final result = await couponRepository.getCouponByCode(event.couponCode);

    result.fold(
      (failure) {
        logger.e(
          'Failed to get coupon ${event.couponCode}: ${failure.message}',
        );
        emit(CouponError(message: failure.message, operation: 'get_details'));
      },
      (coupon) {
        logger.i('Loaded coupon details: ${coupon.name}');
        emit(CouponDetailsLoaded(coupon));
      },
    );
  }
}
