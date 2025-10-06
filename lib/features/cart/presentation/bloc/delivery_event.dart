import 'package:equatable/equatable.dart';

abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object> get props => [];
}

class CheckDeliveryAvailability extends DeliveryEvent {
  final String pincode;
  final double orderValue;
  final int weight;
  final bool isExpress;

  const CheckDeliveryAvailability({
    required this.pincode,
    required this.orderValue,
    this.weight = 1000,
    this.isExpress = false,
  });

  @override
  List<Object> get props => [pincode, orderValue, weight, isExpress];
}


