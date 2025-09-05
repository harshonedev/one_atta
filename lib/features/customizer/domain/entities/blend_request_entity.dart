import 'package:equatable/equatable.dart';

class BlendRequestEntity extends Equatable {
  final Map<String, int> ingredients;
  final int totalWeightG;

  const BlendRequestEntity({
    required this.ingredients,
    required this.totalWeightG,
  });

  @override
  List<Object?> get props => [ingredients, totalWeightG];
}

class SaveBlendEntity extends Equatable {
  final String name;
  final List<AdditiveEntity> additives;
  final bool isPublic;
  final double weightKg;

  const SaveBlendEntity({
    required this.name,
    required this.additives,
    this.isPublic = false,
    required this.weightKg,
  });

  @override
  List<Object?> get props => [name, additives, isPublic, weightKg];
}

class AdditiveEntity extends Equatable {
  final String ingredient;
  final double percentage;

  const AdditiveEntity({required this.ingredient, required this.percentage});

  @override
  List<Object?> get props => [ingredient, percentage];
}

class SavedBlendEntity extends Equatable {
  final String id;
  final String name;
  final List<AdditiveEntity> additives;
  final String createdBy;
  final String shareCode;
  final int shareCount;
  final bool isPublic;
  final double pricePerKg;
  final double totalPrice;
  final int expiryDays;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedBlendEntity({
    required this.id,
    required this.name,
    required this.additives,
    required this.createdBy,
    required this.shareCode,
    required this.shareCount,
    required this.isPublic,
    required this.pricePerKg,
    required this.totalPrice,
    required this.expiryDays,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    additives,
    createdBy,
    shareCode,
    shareCount,
    isPublic,
    pricePerKg,
    totalPrice,
    expiryDays,
    deleted,
    createdAt,
    updatedAt,
  ];
}
