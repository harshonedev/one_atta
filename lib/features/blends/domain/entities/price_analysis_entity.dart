import 'package:equatable/equatable.dart';

class PriceAnalysisEntity extends Equatable {
  final String ingredientId;
  final double percentageChange;
  final String status;
  final double currentPrice;
  final double originalPrice;

  const PriceAnalysisEntity({
    required this.ingredientId,
    required this.percentageChange,
    required this.status,
    required this.currentPrice,
    required this.originalPrice,
  });

  @override
  List<Object?> get props => [
    ingredientId,
    percentageChange,
    status,
    currentPrice,
    originalPrice,
  ];
}

class BlendPriceComparisonEntity extends Equatable {
  final double currentPricePerKg;
  final double originalPricePerKg;
  final double percentageChange;
  final String status;

  const BlendPriceComparisonEntity({
    required this.currentPricePerKg,
    required this.originalPricePerKg,
    required this.percentageChange,
    required this.status,
  });

  @override
  List<Object?> get props => [
    currentPricePerKg,
    originalPricePerKg,
    percentageChange,
    status,
  ];
}

class PricingEntity extends Equatable {
  final PriceDetailsEntity current;
  final PriceDetailsEntity original;

  const PricingEntity({required this.current, required this.original});

  @override
  List<Object?> get props => [current, original];
}

class PriceDetailsEntity extends Equatable {
  final double perKg;

  const PriceDetailsEntity({required this.perKg});

  @override
  List<Object?> get props => [perKg];
}
