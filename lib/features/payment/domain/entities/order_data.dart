import 'package:equatable/equatable.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';

class OrderData extends Equatable {
  final List<OrderItem> items;
  final AddressEntity address;
  final double itemTotal;
  final double couponDiscount;
  final String? couponCode;
  final double loyaltyDiscountAmount;
  final int loyaltyPointsUsed;
  final double deliveryCharges;
  final double codCharges;
  final double totalAmount;

  const OrderData({
    required this.items,
    required this.address,
    required this.itemTotal,
    required this.couponDiscount,
    required this.couponCode,
    required this.loyaltyDiscountAmount,
    required this.deliveryCharges,
    required this.loyaltyPointsUsed,
    required this.codCharges,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'address': address.toJson(),
      'item_total': itemTotal,
      'coupon_discount': couponDiscount,
      'coupon_code': couponCode,
      'loyalty_discount_amount': loyaltyDiscountAmount,
      'delivery_charges': deliveryCharges,
      'cod_charges': codCharges,
      'total_amount': totalAmount,
      'loyalty_points_used': loyaltyPointsUsed,
    };
  }

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      address: AddressEntity.fromJson(json['address']),
      itemTotal: (json['item_total'] as num).toDouble(),
      couponDiscount: (json['coupon_discount'] as num).toDouble(),
      couponCode: json['coupon_code'] as String?,
      loyaltyDiscountAmount: (json['loyalty_discount_amount'] as num)
          .toDouble(),
      deliveryCharges: (json['delivery_charges'] as num).toDouble(),
      codCharges: (json['cod_charges'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      loyaltyPointsUsed: json['loyalty_points_used'] as int,
    );
  }

  @override
  List<Object?> get props => [
    address,
    itemTotal,
    couponDiscount,
    couponCode,
    loyaltyDiscountAmount,
    deliveryCharges,
    loyaltyPointsUsed,
    codCharges,
    totalAmount,
  ];
}
