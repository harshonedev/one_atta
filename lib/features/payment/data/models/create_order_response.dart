import 'package:one_atta/features/payment/data/models/order_model.dart';
import 'package:one_atta/features/payment/data/models/razorpay_details_model.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';
import 'package:one_atta/features/payment/domain/entities/razorpay_details_entity.dart';

/// Response model for create order API
class CreateOrderResponse {
  final OrderEntity order;
  final RazorpayDetailsEntity? razorpay; // null for COD

  const CreateOrderResponse({required this.order, this.razorpay});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      order: OrderModel.fromJson(json['order'] as Map<String, dynamic>),
      razorpay: json['razorpay'] != null
          ? RazorpayDetailsModel.fromJson(
              json['razorpay'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
