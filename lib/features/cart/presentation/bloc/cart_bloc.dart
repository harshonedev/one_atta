import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/cart/domain/entities/cart_entity.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/get_cart_item_count_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/update_cart_item_weight_usecase.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';
import 'package:one_atta/features/coupons/domain/entities/coupon_entity.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final UpdateCartItemWeightUseCase updateCartItemWeightUseCase;
  final ClearCartUseCase clearCartUseCase;
  final GetCartItemCountUseCase getCartItemCountUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartItemQuantityUseCase,
    required this.updateCartItemWeightUseCase,
    required this.clearCartUseCase,
    required this.getCartItemCountUseCase,
  }) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<UpdateItemWeight>(_onUpdateItemWeight);
    on<ClearCart>(_onClearCart);
    on<LoadCartItemCount>(_onLoadCartItemCount);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<ApplyLoyaltyPoints>(_onApplyLoyaltyPoints);
    on<RemoveLoyaltyPoints>(_onRemoveLoyaltyPoints);
    on<UpdateDeliveryCharges>(_onUpdateDeliveryCharges);
    on<SelectAddress>(_onSelectAddress);
    on<ClearSelectedAddress>(_onClearSelectedAddress);
    on<ReloadCart>(_onReloadCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());

    final cartResult = await getCartUseCase();
    final countResult = await getCartItemCountUseCase();

    cartResult.fold((failure) => emit(CartError(message: failure.message)), (
      cart,
    ) {
      countResult.fold(
        (failure) => emit(CartError(message: failure.message)),
        (count) => emit(_calculateCartTotals(cart, count)),
      );
    });
  }

  Future<void> _onReloadCart(ReloadCart event, Emitter<CartState> emit) async {
    if (state is! CartLoaded) {
      return;
    }

    final cartResult = await getCartUseCase();
    final countResult = await getCartItemCountUseCase();

    cartResult.fold((failure) => emit(CartError(message: failure.message)), (
      cart,
    ) {
      countResult.fold((failure) => emit(CartError(message: failure.message)), (
        count,
      ) {
        final currentState = state as CartLoaded;

        emit(
          _calculateCartTotals(
            cart,
            count,
            selectedAddress: currentState.selectedAddress,
            appliedCoupon: currentState.appliedCoupon,
            couponDiscount: currentState.couponDiscount,
            loyaltyDiscount: currentState.loyaltyDiscount,
            loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
            deliveryFee: currentState.deliveryFee,
            deliveryInfo: currentState.deliveryInfo,
          ),
        );
      });
    });
  }

  // Helper method to calculate all cart totals
  CartLoaded _calculateCartTotals(
    CartEntity cart,
    int count, {
    AddressEntity? selectedAddress,
    CouponEntity? appliedCoupon,
    double couponDiscount = 0.0,
    double loyaltyDiscount = 0.0,
    int loyaltyPointsRedeemed = 0,
    double? deliveryFee,
    DeliveryInfo? deliveryInfo,
  }) {
    final mrpTotal = _calculateMrpTotal(cart.items);
    final itemTotal = _calculateItemTotal(cart.items);
    final savingsFromMrp = mrpTotal - itemTotal;
    final totalSavings = savingsFromMrp + (couponDiscount) + (loyaltyDiscount);

    double updatedDeliveryFee = deliveryFee ?? 0.0;
    if (deliveryFee != null && deliveryInfo != null) {
      final deliveryItemTotal = loyaltyDiscount > 0
          ? itemTotal - loyaltyDiscount
          : itemTotal; // Adjust item total if loyalty discount applied

      final isFree =
          deliveryInfo.isDeliveryFree ||
          deliveryItemTotal >= deliveryInfo.deliveryThreshold;

      updatedDeliveryFee = isFree ? 0.0 : deliveryInfo.deliveryFee;

      print(
        'Delivery Free: $isFree, Item Total: $deliveryItemTotal, Loyalty Discount: $loyaltyDiscount, Delivery Threshold: ${deliveryInfo.deliveryThreshold}, Updated Delivery Fee: $updatedDeliveryFee',
      );
    }

    final toPayTotal =
        itemTotal + (updatedDeliveryFee) - (couponDiscount) - (loyaltyDiscount);

    // Preserve existing state values
    final currentState = state is CartLoaded ? state as CartLoaded : null;

    return CartLoaded(
      cart: cart,
      itemCount: count,
      mrpTotal: mrpTotal,
      itemTotal: itemTotal,
      deliveryFee: updatedDeliveryFee,
      deliveryInfo: deliveryInfo,
      couponDiscount: couponDiscount,
      loyaltyDiscount: loyaltyDiscount,
      savingsTotal: totalSavings,
      toPayTotal: toPayTotal < 0 ? 0 : toPayTotal,
      selectedAddress: selectedAddress ?? currentState?.selectedAddress,
      appliedCoupon: appliedCoupon,
      loyaltyPointsRedeemed: loyaltyPointsRedeemed,
      isDiscountApplied: couponDiscount > 0 || loyaltyDiscount > 0,
      discountType: couponDiscount > 0
          ? DiscountType.coupon
          : (loyaltyDiscount > 0 ? DiscountType.loyalty : null),
    );
  }

  double _calculateMrpTotal(List<CartItemEntity> items) {
    return items.fold(0.0, (total, item) => total + (item.mrp * item.quantity));
  }

  double _calculateItemTotal(List<CartItemEntity> items) {
    return items.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }

  Future<void> _onAddItemToCart(
    AddItemToCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCartUseCase(event.item);

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      add(ReloadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await removeFromCartUseCase(event.productId);

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      add(ReloadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    final result = await updateCartItemQuantityUseCase(
      event.productId,
      event.quantity,
    );

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      add(ReloadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onUpdateItemWeight(
    UpdateItemWeight event,
    Emitter<CartState> emit,
  ) async {
    final result = await updateCartItemWeightUseCase(
      event.productId,
      event.weightInKg,
    );

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      add(ReloadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    final result = await clearCartUseCase();

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      emit(const CartCleared(message: 'Cart cleared'));
      add(ReloadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onLoadCartItemCount(
    LoadCartItemCount event,
    Emitter<CartState> emit,
  ) async {
    final result = await getCartItemCountUseCase();

    result.fold((failure) => emit(CartError(message: failure.message)), (
      count,
    ) {
      // If current state is CartLoaded, update only the count
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        emit(
          _calculateCartTotals(
            currentState.cart,
            count,
            selectedAddress: currentState.selectedAddress,
            appliedCoupon: currentState.appliedCoupon,
            couponDiscount: currentState.couponDiscount,
            loyaltyDiscount: currentState.loyaltyDiscount,
            loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
            deliveryFee: currentState.deliveryFee,
            deliveryInfo: currentState.deliveryInfo,
          ),
        );
      }
    });
  }

  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          appliedCoupon: event.coupon,
          couponDiscount: event.discountAmount,
          loyaltyDiscount: currentState.loyaltyDiscount,
          loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
          selectedAddress: currentState.selectedAddress,
          deliveryFee: currentState.deliveryFee,
          deliveryInfo: currentState.deliveryInfo,
        ),
      );
    }
  }

  Future<void> _onRemoveCoupon(
    RemoveCoupon event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          appliedCoupon: null,
          couponDiscount: 0.0,
          loyaltyDiscount: currentState.loyaltyDiscount,
          loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
          selectedAddress: currentState.selectedAddress,
          deliveryFee: currentState.deliveryFee,
          deliveryInfo: currentState.deliveryInfo,
        ),
      );
    }
  }

  Future<void> _onApplyLoyaltyPoints(
    ApplyLoyaltyPoints event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          appliedCoupon: currentState.appliedCoupon,
          couponDiscount: currentState.couponDiscount,
          loyaltyDiscount: event.discountAmount,
          loyaltyPointsRedeemed: event.points,
          selectedAddress: currentState.selectedAddress,
          deliveryFee: currentState.deliveryFee,
          deliveryInfo: currentState.deliveryInfo,
        ),
      );
    }
  }

  Future<void> _onRemoveLoyaltyPoints(
    RemoveLoyaltyPoints event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          appliedCoupon: currentState.appliedCoupon,
          couponDiscount: currentState.couponDiscount,
          loyaltyDiscount: 0.0,
          loyaltyPointsRedeemed: 0,
          selectedAddress: currentState.selectedAddress,
          deliveryFee: currentState.deliveryFee,
          deliveryInfo: currentState.deliveryInfo,
        ),
      );
    }
  }

  Future<void> _onUpdateDeliveryCharges(
    UpdateDeliveryCharges event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      DeliveryInfo? deliveryInfo;
      if (event.deliveryCharges != null &&
          event.deliveryThreshold != null &&
          event.isDeliveryFree != null) {
        deliveryInfo = DeliveryInfo(
          deliveryFee: event.deliveryCharges!,
          isDeliveryFree: event.isDeliveryFree!,
          deliveryThreshold: event.deliveryThreshold!,
        );
      }
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          deliveryFee: event.deliveryCharges,
          deliveryInfo: deliveryInfo,
          selectedAddress: currentState.selectedAddress,
          appliedCoupon: currentState.appliedCoupon,
          couponDiscount: currentState.couponDiscount,
          loyaltyDiscount: currentState.loyaltyDiscount,
          loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
        ),
      );
    }
  }

  Future<void> _onSelectAddress(
    SelectAddress event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          selectedAddress: event.address,
          appliedCoupon: currentState.appliedCoupon,
          couponDiscount: currentState.couponDiscount,
          loyaltyDiscount: currentState.loyaltyDiscount,
          loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
          deliveryFee: currentState.deliveryFee,
          deliveryInfo: currentState.deliveryInfo,
        ),
      );
    }
  }

  Future<void> _onClearSelectedAddress(
    ClearSelectedAddress event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(
        _calculateCartTotals(
          currentState.cart,
          currentState.itemCount,
          selectedAddress: null,
          appliedCoupon: currentState.appliedCoupon,
          couponDiscount: currentState.couponDiscount,
          loyaltyDiscount: currentState.loyaltyDiscount,
          loyaltyPointsRedeemed: currentState.loyaltyPointsRedeemed,
          deliveryFee: currentState.deliveryFee,
          deliveryInfo: currentState.deliveryInfo,
        ),
      );
    }
  }
}
