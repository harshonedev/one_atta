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
  final int weightKg;

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
    required this.weightKg,
  });

  SavedBlendEntity copyWith({
    String? id,
    String? name,
    List<AdditiveEntity>? additives,
    String? createdBy,
    String? shareCode,
    int? shareCount,
    bool? isPublic,
    double? pricePerKg,
    double? totalPrice,
    int? expiryDays,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? weightKg,
  }) {
    return SavedBlendEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      additives: additives ?? this.additives,
      createdBy: createdBy ?? this.createdBy,
      shareCode: shareCode ?? this.shareCode,
      shareCount: shareCount ?? this.shareCount,
      isPublic: isPublic ?? this.isPublic,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalPrice: totalPrice ?? this.totalPrice,
      expiryDays: expiryDays ?? this.expiryDays,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weightKg: weightKg ?? this.weightKg,
    );
  }

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
    weightKg,
  ];
}
