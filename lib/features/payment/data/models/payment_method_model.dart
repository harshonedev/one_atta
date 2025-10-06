import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.name,
    required super.type,
    super.iconPath,
    super.isEnabled,
    super.description,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      iconPath: json['icon_path'],
      isEnabled: json['is_enabled'] ?? true,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon_path': iconPath,
      'is_enabled': isEnabled,
      'description': description,
    };
  }

  PaymentMethodModel copyWith({
    String? id,
    String? name,
    String? type,
    String? iconPath,
    bool? isEnabled,
    String? description,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      isEnabled: isEnabled ?? this.isEnabled,
      description: description ?? this.description,
    );
  }
}
