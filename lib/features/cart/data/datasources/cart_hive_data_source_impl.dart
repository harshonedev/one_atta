import 'package:hive_flutter/hive_flutter.dart';
import 'package:one_atta/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:one_atta/features/cart/data/models/cart_item_model.dart';

class CartHiveDataSourceImpl implements CartLocalDataSource {
  static const String _boxName = 'cart_items';
  Box<CartItemModel>? _cartBox;

  Future<Box<CartItemModel>> get cartBox async {
    if (_cartBox != null && _cartBox!.isOpen) {
      return _cartBox!;
    }
    _cartBox = await Hive.openBox<CartItemModel>(_boxName);
    return _cartBox!;
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final box = await cartBox;
    final items = box.values.toList();
    // Sort by creation date (newest first)
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> insertCartItem(CartItemModel item) async {
    final box = await cartBox;

    // Check if item with same productId already exists
    final existingItemKey = box.keys.firstWhere(
      (key) => box.get(key)?.productId == item.productId,
      orElse: () => null,
    );

    if (existingItemKey != null) {
      // Update existing item by adding quantities
      final existingItem = box.get(existingItemKey)!;
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
        updatedAt: DateTime.now(),
      );
      await box.put(existingItemKey, updatedItem);
    } else {
      // Insert new item with productId as key for easy retrieval
      await box.put(item.productId, item);
    }
  }

  @override
  Future<void> updateCartItem(CartItemModel item) async {
    final box = await cartBox;
    await box.put(item.productId, item);
  }

  @override
  Future<void> deleteCartItem(String productId) async {
    final box = await cartBox;
    await box.delete(productId);
  }

  @override
  Future<void> clearCart() async {
    final box = await cartBox;
    await box.clear();
  }

  @override
  Future<int> getCartItemCount() async {
    final box = await cartBox;
    int totalCount = 0;
    for (final item in box.values) {
      totalCount += item.quantity;
    }
    return totalCount;
  }

  @override
  Future<CartItemModel?> getCartItemByProductId(String productId) async {
    final box = await cartBox;
    return box.get(productId);
  }

  /// Initialize Hive and register adapters
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Register the CartItemModel adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CartItemModelAdapter());
    }
  }

  /// Close all boxes (call this when app is being disposed)
  static Future<void> close() async {
    await Hive.close();
  }
}
