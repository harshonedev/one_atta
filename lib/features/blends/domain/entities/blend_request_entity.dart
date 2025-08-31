import 'package:equatable/equatable.dart';

class CreateBlendEntity extends Equatable {
  final String? name;
  final List<CreateAdditiveEntity> additives;
  final bool? isPublic;
  final double? weightKg;

  const CreateBlendEntity({
    this.name,
    required this.additives,
    this.isPublic,
    this.weightKg,
  });

  @override
  List<Object?> get props => [name, additives, isPublic, weightKg];
}

class CreateAdditiveEntity extends Equatable {
  final String ingredient;
  final double percentage;

  const CreateAdditiveEntity({
    required this.ingredient,
    required this.percentage,
  });

  @override
  List<Object?> get props => [ingredient, percentage];
}

class UpdateBlendEntity extends Equatable {
  final String? name;
  final String? baseGrain;
  final List<CreateAdditiveEntity>? additives;
  final bool? isPublic;
  final double? pricePerKg;

  const UpdateBlendEntity({
    this.name,
    this.baseGrain,
    this.additives,
    this.isPublic,
    this.pricePerKg,
  });

  @override
  List<Object?> get props => [name, baseGrain, additives, isPublic, pricePerKg];
}
