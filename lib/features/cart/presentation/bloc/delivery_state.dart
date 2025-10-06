import 'package:equatable/equatable.dart';
import 'package:one_atta/features/cart/domain/entities/delivery_info_entity.dart';

abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryLoaded extends DeliveryState {
  final String pincode;
  final DeliveryInfoEntity? deliveryInfo;
  final bool isExpressDelivery;
  final bool isDeliveryAvailable;
  final double deliveryCharges;
  final double codCharges;
  final String etaDisplay;
  final bool isFreeDelivery;
  final double freeDeliveryThreshold;
  final bool codAvailable;
  final int minEta;
  final int maxEta;
  const DeliveryLoaded({
    required this.pincode,
    this.deliveryInfo,
    this.isExpressDelivery = false,
    this.isDeliveryAvailable = false,
    this.deliveryCharges = 0.0,
    this.codCharges = 0.0,
    this.etaDisplay = '',
    this.isFreeDelivery = false,
    this.freeDeliveryThreshold = 0.0,
    this.codAvailable = false,
    this.minEta = 0,
    this.maxEta = 0,
  });

  @override
  List<Object?> get props => [
    pincode,
    deliveryInfo,
    isExpressDelivery,
    isDeliveryAvailable,
    deliveryCharges,
    codCharges,
    etaDisplay,
    isFreeDelivery,
    freeDeliveryThreshold,
    codAvailable,
    minEta,
    maxEta,
  ];

  DeliveryLoaded copyWith({
    String? pincode,
    DeliveryInfoEntity? deliveryInfo,
    bool? isExpressDelivery,
    bool? isDeliveryAvailable,
    double? deliveryCharges,
    double? codCharges,
    String? etaDisplay,
    bool? isFreeDelivery,
    double? freeDeliveryThreshold,
    bool? codAvailable,
    int? minEta,
    int? maxEta,
  }) {
    return DeliveryLoaded(
      pincode: pincode ?? this.pincode,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      isExpressDelivery: isExpressDelivery ?? this.isExpressDelivery,
      isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      codCharges: codCharges ?? this.codCharges,
      etaDisplay: etaDisplay ?? this.etaDisplay,
      isFreeDelivery: isFreeDelivery ?? this.isFreeDelivery,
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      codAvailable: codAvailable ?? this.codAvailable,
      minEta: minEta ?? this.minEta,
      maxEta: maxEta ?? this.maxEta,
    );
  }

  /// Calculate total delivery charges including COD if applicable
  double get totalDeliveryCharges {
    return deliveryCharges + (codAvailable ? codCharges : 0.0);
  }

  /// Get delivery message for UI display
  String get deliveryMessage {
    if (!isDeliveryAvailable) {
      return 'Delivery not available for pincode $pincode';
    }

    if (isExpressDelivery &&
        deliveryInfo?.zoneInfo.expressDelivery.available == true) {
      return 'Express delivery available - ${deliveryInfo!.zoneInfo.expressDelivery.etaDisplay}';
    }

    return 'Delivery available - $etaDisplay';
  }
}

class DeliveryError extends DeliveryState {
  final String message;
  final String? pincode;

  const DeliveryError({required this.message, this.pincode});

  @override
  List<Object?> get props => [message, pincode];
}

class DeliveryNotAvailable extends DeliveryState {
  final String pincode;
  final String message;

  const DeliveryNotAvailable({
    required this.pincode,
    this.message = 'Delivery not available for this pincode',
  });

  @override
  List<Object> get props => [pincode, message];
}
