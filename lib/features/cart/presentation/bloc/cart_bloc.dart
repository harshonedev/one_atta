import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/get_cart_item_count_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;
  final GetCartItemCountUseCase getCartItemCountUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartItemQuantityUseCase,
    required this.clearCartUseCase,
    required this.getCartItemCountUseCase,
  }) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCart>(_onClearCart);
    on<LoadCartItemCount>(_onLoadCartItemCount);
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
        (count) => emit(CartLoaded(cart: cart, itemCount: count)),
      );
    });
  }

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
        emit(CartLoaded(cart: currentState.cart, itemCount: count));
      }
    });
  }
}
