import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;
  final String type; // 'COD', 'UPI', 'Card', 'Wallet'
  final String? iconPath;
  final bool isEnabled;
  final String? description;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.type,
    this.iconPath,
    this.isEnabled = true,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, type, iconPath, isEnabled, description];
}
