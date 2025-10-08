import 'package:flutter_bloc/flutter_bloc.dart';
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

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final UpdateCartItemWeightUseCase updateCartItemWeightUseCase;
  final ClearCartUseCase clearCartUseCase;
  final GetCartItemCountUseCase getCartItemCountUseCase;

  // Track current pricing state
  double _couponDiscount = 0.0;
  double _loyaltyDiscount = 0.0;
  double _deliveryCharges = 0.0;

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
    on<UpdateCartPricing>(_onUpdateCartPricing);
    on<UpdateDeliveryCharges>(_onUpdateDeliveryCharges);
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

  // Helper method to calculate all cart totals
  CartLoaded _calculateCartTotals(CartEntity cart, int count) {
    final mrpTotal = _calculateMrpTotal(cart.items);
    final itemTotal = _calculateItemTotal(cart.items);
    final deliveryFee =
        _deliveryCharges; // Use delivery charges from delivery bloc
    final savingsFromMrp = mrpTotal - itemTotal;
    final totalSavings = savingsFromMrp + _couponDiscount + _loyaltyDiscount;
    final toPayTotal =
        itemTotal + deliveryFee - _couponDiscount - _loyaltyDiscount;

    return CartLoaded(
      cart: cart,
      itemCount: count,
      mrpTotal: mrpTotal,
      itemTotal: itemTotal,
      deliveryFee: deliveryFee,
      couponDiscount: _couponDiscount,
      loyaltyDiscount: _loyaltyDiscount,
      savingsTotal: totalSavings,
      toPayTotal: toPayTotal < 0 ? 0 : toPayTotal,
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

  // Removed: Delivery fee is now managed by delivery bloc
  // and updated via UpdateDeliveryCharges event

  Future<void> _onAddItemToCart(
    AddItemToCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCartUseCase(event.item);

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      emit(const CartItemAdded(message: 'Item added to cart'));
      add(LoadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await removeFromCartUseCase(event.productId);

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      emit(const CartItemRemoved(message: 'Item removed from cart'));
      add(LoadCart()); // Reload cart to update UI
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
      add(LoadCart()); // Reload cart to update UI
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
      add(LoadCart()); // Reload cart to update UI
    });
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    final result = await clearCartUseCase();

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      emit(const CartCleared(message: 'Cart cleared'));
      add(LoadCart()); // Reload cart to update UI
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
        emit(_calculateCartTotals(currentState.cart, count));
      }
    });
  }

  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CartState> emit,
  ) async {
    _couponDiscount = event.discountAmount;

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(_calculateCartTotals(currentState.cart, currentState.itemCount));
    }
  }

  Future<void> _onRemoveCoupon(
    RemoveCoupon event,
    Emitter<CartState> emit,
  ) async {
    _couponDiscount = 0.0;

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(_calculateCartTotals(currentState.cart, currentState.itemCount));
    }
  }

  Future<void> _onApplyLoyaltyPoints(
    ApplyLoyaltyPoints event,
    Emitter<CartState> emit,
  ) async {
    _loyaltyDiscount = event.discountAmount;

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(_calculateCartTotals(currentState.cart, currentState.itemCount));
    }
  }

  Future<void> _onRemoveLoyaltyPoints(
    RemoveLoyaltyPoints event,
    Emitter<CartState> emit,
  ) async {
    _loyaltyDiscount = 0.0;

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(_calculateCartTotals(currentState.cart, currentState.itemCount));
    }
  }

  Future<void> _onUpdateCartPricing(
    UpdateCartPricing event,
    Emitter<CartState> emit,
  ) async {
    if (event.couponDiscount != null) {
      _couponDiscount = event.couponDiscount!;
    }

    if (event.loyaltyDiscount != null) {
      _loyaltyDiscount = event.loyaltyDiscount!;
    }

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(_calculateCartTotals(currentState.cart, currentState.itemCount));
    }
  }

  Future<void> _onUpdateDeliveryCharges(
    UpdateDeliveryCharges event,
    Emitter<CartState> emit,
  ) async {
    _deliveryCharges = event.deliveryCharges;

    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(_calculateCartTotals(currentState.cart, currentState.itemCount));
    }
  }
}
