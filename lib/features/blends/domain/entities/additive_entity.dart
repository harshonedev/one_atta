import 'package:equatable/equatable.dart';

class AdditiveEntity extends Equatable {
  final String ingredient;
  final double percentage;
  final OriginalDetailsEntity originalDetails;

  const AdditiveEntity({
    required this.ingredient,
    required this.percentage,
    required this.originalDetails,
  });

  @override
  List<Object?> get props => [ingredient, percentage, originalDetails];
}

class OriginalDetailsEntity extends Equatable {
  final String sku;
  final String name;
  final double pricePerKg;

  const OriginalDetailsEntity({
    required this.sku,
    required this.name,
    required this.pricePerKg,
  });

  @override
  List<Object?> get props => [sku, name, pricePerKg];
}
