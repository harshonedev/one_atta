import 'package:one_atta/features/cart/domain/entities/delivery_info_entity.dart';

class DeliveryResponseModel {
  final bool success;
  final String message;
  final DeliveryInfoModel? data;
  const DeliveryResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeliveryResponseModel.fromJson(Map<String, dynamic> json) {
    return DeliveryResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? DeliveryInfoModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data != null ? (data as DeliveryInfoModel).toJson() : null,
    };
  }
}

class DeliveryInfoModel extends DeliveryInfoEntity {
  const DeliveryInfoModel({
    required super.available,
    required super.pincode,
    required super.zoneInfo,
  });

  factory DeliveryInfoModel.fromJson(Map<String, dynamic> json) {
    return DeliveryInfoModel(
      available: json['available'] as bool,
      pincode: json['pincode'] as String,
      zoneInfo: ZoneInfoModel.fromJson(
        json['zone_info'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'pincode': pincode,
      'zone_info': (zoneInfo as ZoneInfoModel).toJson(),
    };
  }

  DeliveryInfoEntity toEntity() {
    return DeliveryInfoEntity(
      available: available,
      pincode: pincode,
      zoneInfo: zoneInfo,
    );
  }

  DeliveryInfoModel copyWith({
    bool? available,
    String? pincode,
    ZoneInfoModel? zoneInfo,
  }) {
    return DeliveryInfoModel(
      available: available ?? this.available,
      pincode: pincode ?? this.pincode,
      zoneInfo: zoneInfo ?? this.zoneInfo,
    );
  }
}

class ZoneInfoModel extends ZoneInfoEntity {
  const ZoneInfoModel({
    required super.zoneName,
    required super.deliveryCharges,
    required super.codCharges,
    required super.totalCharges,
    required super.isFreeDelivery,
    required super.eta,
    required super.etaDisplay,
    required super.codAvailable,
    required super.expressDelivery,
    required super.freeDeliveryThreshold,
  });

  factory ZoneInfoModel.fromJson(Map<String, dynamic> json) {
    return ZoneInfoModel(
      zoneName: json['zone_name'] as String,
      deliveryCharges: (json['delivery_charges'] as num).toDouble(),
      codCharges: (json['cod_charges'] as num).toDouble(),
      totalCharges: (json['total_charges'] as num).toDouble(),
      isFreeDelivery: json['is_free_delivery'] as bool,
      eta: EtaModel.fromJson(json['eta'] as Map<String, dynamic>),
      etaDisplay: json['eta_display'] as String,
      codAvailable: json['cod_available'] as bool,
      expressDelivery: ExpressDeliveryModel.fromJson(
        json['express_delivery'] as Map<String, dynamic>,
      ),
      freeDeliveryThreshold: (json['free_delivery_threshold'] as num)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone_name': zoneName,
      'delivery_charges': deliveryCharges,
      'cod_charges': codCharges,
      'total_charges': totalCharges,
      'is_free_delivery': isFreeDelivery,
      'eta': (eta as EtaModel).toJson(),
      'eta_display': etaDisplay,
      'cod_available': codAvailable,
      'express_delivery': (expressDelivery as ExpressDeliveryModel).toJson(),
      'free_delivery_threshold': freeDeliveryThreshold,
    };
  }

  ZoneInfoEntity toEntity() {
    return ZoneInfoEntity(
      zoneName: zoneName,
      deliveryCharges: deliveryCharges,
      codCharges: codCharges,
      totalCharges: totalCharges,
      isFreeDelivery: isFreeDelivery,
      eta: eta,
      etaDisplay: etaDisplay,
      codAvailable: codAvailable,
      expressDelivery: expressDelivery,
      freeDeliveryThreshold: freeDeliveryThreshold,
    );
  }

  ZoneInfoModel copyWith({
    String? zoneName,
    double? deliveryCharges,
    double? codCharges,
    double? totalCharges,
    bool? isFreeDelivery,
    EtaModel? eta,
    String? etaDisplay,
    bool? codAvailable,
    ExpressDeliveryModel? expressDelivery,
    double? freeDeliveryThreshold,
  }) {
    return ZoneInfoModel(
      zoneName: zoneName ?? this.zoneName,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      codCharges: codCharges ?? this.codCharges,
      totalCharges: totalCharges ?? this.totalCharges,
      isFreeDelivery: isFreeDelivery ?? this.isFreeDelivery,
      eta: eta ?? this.eta,
      etaDisplay: etaDisplay ?? this.etaDisplay,
      codAvailable: codAvailable ?? this.codAvailable,
      expressDelivery: expressDelivery ?? this.expressDelivery,
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
    );
  }
}

class EtaModel extends EtaEntity {
  const EtaModel({
    required super.min,
    required super.max,
    required super.display,
  });

  factory EtaModel.fromJson(Map<String, dynamic> json) {
    return EtaModel(
      min: json['min'] as int,
      max: json['max'] as int,
      display: json['display'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max, 'display': display};
  }

  EtaEntity toEntity() {
    return EtaEntity(min: min, max: max, display: display);
  }

  EtaModel copyWith({int? min, int? max, String? display}) {
    return EtaModel(
      min: min ?? this.min,
      max: max ?? this.max,
      display: display ?? this.display,
    );
  }
}

class ExpressDeliveryModel extends ExpressDeliveryEntity {
  const ExpressDeliveryModel({
    required super.available,
    required super.charges,
    required super.etaMin,
    required super.etaMax,
  });

  factory ExpressDeliveryModel.fromJson(Map<String, dynamic> json) {
    return ExpressDeliveryModel(
      available: json['available'] as bool,
      charges: (json['charges'] as num).toDouble(),
      etaMin: json['eta_min'] as int,
      etaMax: json['eta_max'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'charges': charges,
      'eta_min': etaMin,
      'eta_max': etaMax,
    };
  }

  ExpressDeliveryEntity toEntity() {
    return ExpressDeliveryEntity(
      available: available,
      charges: charges,
      etaMin: etaMin,
      etaMax: etaMax,
    );
  }

  ExpressDeliveryModel copyWith({
    bool? available,
    double? charges,
    int? etaMin,
    int? etaMax,
  }) {
    return ExpressDeliveryModel(
      available: available ?? this.available,
      charges: charges ?? this.charges,
      etaMin: etaMin ?? this.etaMin,
      etaMax: etaMax ?? this.etaMax,
    );
  }
}
