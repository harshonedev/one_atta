import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int? id;
  final String productId;
  final String productName;
  final String productType; // 'recipe' or 'blend'
  final int quantity;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartItemEntity({
    this.id,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalPrice => price * quantity;

  CartItemEntity copyWith({
    int? id,
    String? productId,
    String? productName,
    String? productType,
    int? quantity,
    double? price,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
  ];
}
