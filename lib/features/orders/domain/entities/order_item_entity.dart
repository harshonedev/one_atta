import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String itemType; // 'Product' or 'Blend'
  final String itemId;
  final String itemName;
  final String? itemSku;
  final double quantity;
  final double pricePerKg;
  final double totalPrice;
  final int weightInKg;
  final int? expiryDays; // Number of days until product expires from order date

  const OrderItemEntity({
    required this.itemType,
    required this.itemId,
    required this.itemName,
    this.itemSku,
    required this.quantity,
    required this.pricePerKg,
    required this.totalPrice,
    required this.weightInKg,
    this.expiryDays,
  });

  @override
  List<Object?> get props => [
    itemType,
    itemId,
    itemName,
    itemSku,
    quantity,
    pricePerKg,
    totalPrice,
    weightInKg,
    expiryDays,
  ];
}
