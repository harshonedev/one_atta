import 'package:one_atta/features/orders/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.itemType,
    required super.itemId,
    required super.itemName,
    super.itemSku,
    required super.quantity,
    required super.pricePerKg,
    required super.totalPrice,
    required super.weightInKg,
    super.expiryDays,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      itemType: json['item_type'] ?? '',
      itemId: json['item']['_id'] ?? json['item'] ?? '',
      itemName: json['item']['name'] ?? '',
      itemSku: json['item']['sku'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      weightInKg: json['weight_in_kg'] ?? 0,
      expiryDays: json['item']['expiry_days'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_type': itemType,
      'item': itemId,
      'quantity': quantity,
      'price_per_kg': pricePerKg,
      'total_price': totalPrice,
      'weight_in_kg': weightInKg,
      if (expiryDays != null) 'expiry_days': expiryDays,
    };
  }

  OrderItemModel copyWith({
    String? itemType,
    String? itemId,
    String? itemName,
    String? itemSku,
    double? quantity,
    double? pricePerKg,
    double? totalPrice,
    int? weightInKg,
    int? expiryDays,
  }) {
    return OrderItemModel(
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemSku: itemSku ?? this.itemSku,
      quantity: quantity ?? this.quantity,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalPrice: totalPrice ?? this.totalPrice,
      weightInKg: weightInKg ?? this.weightInKg,
      expiryDays: expiryDays ?? this.expiryDays,
    );
  }
}
