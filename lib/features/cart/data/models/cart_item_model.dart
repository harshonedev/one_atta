import 'package:hive/hive.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 0)
class CartItemModel extends CartItemEntity {
  @HiveField(0)
  @override
  final int? id;

  @HiveField(1)
  @override
  final String productId;

  @HiveField(2)
  @override
  final String productName;

  @HiveField(3)
  @override
  final String productType;

  @HiveField(4)
  @override
  final int quantity;

  @HiveField(5)
  @override
  final double price;

  @HiveField(6)
  @override
  final String? imageUrl;

  @HiveField(7)
  @override
  final DateTime createdAt;

  @HiveField(8)
  @override
  final DateTime updatedAt;

  const CartItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
         id: id,
         productId: productId,
         productName: productName,
         productType: productType,
         quantity: quantity,
         price: price,
         imageUrl: imageUrl,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as int?,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      productType: map['product_type'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_type': productType,
      'quantity': quantity,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      productType: entity.productType,
      quantity: entity.quantity,
      price: entity.price,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  CartItemModel copyWith({
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
    return CartItemModel(
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
}
