import 'package:one_atta/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> insertCartItem(CartItemModel item);
  Future<void> updateCartItem(CartItemModel item);
  Future<void> deleteCartItem(String productId);
  Future<void> clearCart();
  Future<int> getCartItemCount();
  Future<CartItemModel?> getCartItemByProductId(String productId);
}
