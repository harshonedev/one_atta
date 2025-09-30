import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int? id;
  final String productId;
  final String productName;
  final String productType; // 'product' or 'blend'
  final int quantity;
  final double price;
  final double mrp;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int weightInKg; // in kg

  const CartItemEntity({
    this.id,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.price,
    required this.mrp,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.weightInKg = 1,
  });

  double get totalPrice => price * quantity;

  CartItemEntity copyWith({
    int? id,
    String? productId,
    String? productName,
    String? productType,
    int? quantity,
    double? price,
    double? mrp,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? weightInKg,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weightInKg: weightInKg ?? this.weightInKg,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productType,
    quantity,
    price,
    imageUrl,
    createdAt,
    updatedAt,
    weightInKg,
    mrp,
  ];
}
