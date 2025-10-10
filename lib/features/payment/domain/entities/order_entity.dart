import 'package:equatable/equatable.dart';

/// Entity representing an order from the payment system
class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String
  status; // 'pending', 'accepted', 'processing', 'shipped', 'delivered', 'cancelled', 'rejected'
  final String paymentStatus; // 'pending', 'completed', 'failed', 'refunded'
  final String paymentMethod; // 'Razorpay', 'COD', 'UPI', 'Card', 'Wallet'
  final String? actualPaymentMethod; // Actual method used (e.g., 'UPI', 'Card')
  final bool paymentVerified;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final double subtotal;
  final double discountAmount;
  final bool isDiscountAvailed; // NEW: Whether discount was applied
  final String? discountType; // NEW: "loyalty" or "coupon" or null
  final double loyaltyDiscountAmount;
  final double deliveryCharges;
  final double codCharges;
  final double totalAmount;
  final String deliveryAddressId;
  final List<String> contactNumbers;
  final String? couponCode;
  final int loyaltyPointsUsed;
  final DateTime? paymentCompletedAt;
  final String? paymentFailureReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.actualPaymentMethod,
    required this.paymentVerified,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.subtotal,
    required this.discountAmount,
    this.isDiscountAvailed = false, // NEW: default false
    this.discountType, // NEW: nullable
    required this.loyaltyDiscountAmount,
    required this.deliveryCharges,
    required this.codCharges,
    required this.totalAmount,
    required this.deliveryAddressId,
    required this.contactNumbers,
    this.couponCode,
    required this.loyaltyPointsUsed,
    this.paymentCompletedAt,
    this.paymentFailureReason,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'actualPaymentMethod': actualPaymentMethod,
      'paymentVerified': paymentVerified,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'isDiscountAvailed': isDiscountAvailed,
      'discountType': discountType,
      'loyaltyDiscountAmount': loyaltyDiscountAmount,
      'deliveryCharges': deliveryCharges,
      'codCharges': codCharges,
      'totalAmount': totalAmount,
      'deliveryAddressId': deliveryAddressId,
      'contactNumbers': contactNumbers,
      'couponCode': couponCode,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'paymentCompletedAt': paymentCompletedAt?.toIso8601String(),
      'paymentFailureReason': paymentFailureReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String,
      actualPaymentMethod: json['actualPaymentMethod'] as String?,
      paymentVerified: json['paymentVerified'] as bool,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      isDiscountAvailed: json['isDiscountAvailed'] as bool? ?? false,
      discountType: json['discountType'] as String?,
      loyaltyDiscountAmount: (json['loyaltyDiscountAmount'] as num).toDouble(),
      deliveryCharges: (json['deliveryCharges'] as num).toDouble(),
      codCharges: (json['codCharges'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddressId: json['deliveryAddressId'] as String,
      contactNumbers: (json['contactNumbers'] as List)
          .map((e) => e as String)
          .toList(),
      couponCode: json['couponCode'] as String?,
      loyaltyPointsUsed: json['loyaltyPointsUsed'] as int,
      paymentCompletedAt: json['paymentCompletedAt'] != null
          ? DateTime.parse(json['paymentCompletedAt'] as String)
          : null,
      paymentFailureReason: json['paymentFailureReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    paymentStatus,
    paymentMethod,
    actualPaymentMethod,
    paymentVerified,
    razorpayOrderId,
    razorpayPaymentId,
    subtotal,
    discountAmount,
    isDiscountAvailed,
    discountType,
    loyaltyDiscountAmount,
    deliveryCharges,
    codCharges,
    totalAmount,
    deliveryAddressId,
    contactNumbers,
    couponCode,
    loyaltyPointsUsed,
    paymentCompletedAt,
    paymentFailureReason,
    createdAt,
    updatedAt,
    items,
  ];
}

class OrderItem extends Equatable {
  final String id;
  final String type;
  final int quantity;
  final int weightInKg; 
  final double pricePerKg; // NEW: Price per kg
  final double totalPrice; // NEW: Total price for this item

  const OrderItem({
    required this.id,
    required this.type,
    required this.quantity,
    required this.weightInKg,
    required this.pricePerKg,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['item'] as String,
      type: json['item_type'] as String,
      quantity: json['quantity'] as int,
      weightInKg: (json['weight_in_kg'] as int),
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': id,
      'item_type': type,
      'quantity': quantity,
      'weight_in_kg': weightInKg,
      'price_per_kg': pricePerKg,
      'total_price': totalPrice,
    };
  }

  @override
  List<Object> get props => [
    id,
    type,
    quantity,
    weightInKg,
    pricePerKg,
    totalPrice,
  ];
}
