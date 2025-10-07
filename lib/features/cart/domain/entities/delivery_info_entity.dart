import 'package:equatable/equatable.dart';

class DeliveryInfoEntity extends Equatable {
  final bool available;
  final String pincode;
  final ZoneInfoEntity zoneInfo;

  const DeliveryInfoEntity({
    required this.available,
    required this.pincode,
    required this.zoneInfo,
  });

  @override
  List<Object?> get props => [available, pincode, zoneInfo];

  @override
  String toString() {
    return 'DeliveryInfoEntity(available: $available, pincode: $pincode, zoneInfo: $zoneInfo)';
  }
}

class ZoneInfoEntity extends Equatable {
  final String zoneName;
  final double deliveryCharges;
  final double codCharges;
  final double totalCharges;
  final bool isFreeDelivery;
  final EtaEntity eta;
  final String etaDisplay;
  final bool codAvailable;
  final ExpressDeliveryEntity expressDelivery;
  final double freeDeliveryThreshold;

  const ZoneInfoEntity({
    required this.zoneName,
    required this.deliveryCharges,
    required this.codCharges,
    required this.totalCharges,
    required this.isFreeDelivery,
    required this.eta,
    required this.etaDisplay,
    required this.codAvailable,
    required this.expressDelivery,
    required this.freeDeliveryThreshold,
  });

  @override
  List<Object?> get props => [
    zoneName,
    deliveryCharges,
    codCharges,
    totalCharges,
    isFreeDelivery,
    eta,
    etaDisplay,
    codAvailable,
    expressDelivery,
    freeDeliveryThreshold,
  ];

  @override
  String toString() {
    return 'ZoneInfoEntity(zoneName: $zoneName, deliveryCharges: $deliveryCharges, codCharges: $codCharges, totalCharges: $totalCharges, isFreeDelivery: $isFreeDelivery, eta: $eta, etaDisplay: $etaDisplay, codAvailable: $codAvailable, expressDelivery: $expressDelivery, freeDeliveryThreshold: $freeDeliveryThreshold)';
  }
}

class EtaEntity extends Equatable {
  final int min;
  final int max;
  final String display;

  const EtaEntity({
    required this.min,
    required this.max,
    required this.display,
  });

  @override
  List<Object?> get props => [min, max, display];

  @override
  String toString() {
    return 'EtaEntity(min: $min, max: $max, display: $display)';
  }
}

class ExpressDeliveryEntity extends Equatable {
  final bool available;
  final double charges;
  final int etaMin;
  final int etaMax;

  const ExpressDeliveryEntity({
    required this.available,
    required this.charges,
    required this.etaMin,
    required this.etaMax,
  });

  /// Get the ETA display string for express delivery
  String get etaDisplay {
    if (etaMin == etaMax) {
      return '$etaMin day${etaMin == 1 ? '' : 's'}';
    }
    return '$etaMin-$etaMax days';
  }

  @override
  List<Object?> get props => [available, charges, etaMin, etaMax];

  @override
  String toString() {
    return 'ExpressDeliveryEntity(available: $available, charges: $charges, etaMin: $etaMin, etaMax: $etaMax)';
  }
}
