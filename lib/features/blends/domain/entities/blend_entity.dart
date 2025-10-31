import 'package:equatable/equatable.dart';
import 'package:one_atta/features/blends/domain/entities/additive_entity.dart';
import 'package:one_atta/features/blends/domain/entities/created_by_entity.dart';
import 'package:one_atta/features/blends/domain/entities/price_analysis_entity.dart';

class BlendEntity extends Equatable {
  final String id;
  final String name;
  final List<AdditiveEntity> additives;
  final String createdBy;
  final String shareCode;
  final int shareCount;
  final bool isPublic;
  final double pricePerKg;
  final double? totalPrice;
  final int expiryDays;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BlendEntity({
    required this.id,
    required this.name,
    required this.additives,
    required this.createdBy,
    required this.shareCode,
    required this.shareCount,
    required this.isPublic,
    required this.pricePerKg,
    this.totalPrice,
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

class BlendDetailsEntity extends Equatable {
  final String id;
  final String name;
  final List<AdditiveEntity> additives;
  final CreatedByEntity createdBy;
  final String shareCode;
  final int shareCount;
  final bool isPublic;
  final double pricePerKg;
  final double? totalPrice;
  final int expiryDays;
  final List<PriceAnalysisEntity>? priceAnalysis;
  final BlendPriceComparisonEntity? blendPriceComparison;
  final PricingEntity? pricing;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BlendDetailsEntity({
    required this.id,
    required this.name,
    required this.additives,
    required this.createdBy,
    required this.shareCode,
    required this.shareCount,
    required this.isPublic,
    required this.pricePerKg,
    this.totalPrice,
    required this.expiryDays,
    this.priceAnalysis,
    this.blendPriceComparison,
    this.pricing,
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
    priceAnalysis,
    blendPriceComparison,
    pricing,
    createdAt,
    updatedAt,
  ];
}

class PublicBlendEntity extends Equatable {
  final String id;
  final String name;
  final List<AdditiveEntity> additives;
  final CreatedByEntity createdBy;
  final String shareCode;
  final int shareCount;
  final bool isPublic;
  final double pricePerKg;
  final int expiryDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PublicBlendEntity({
    required this.id,
    required this.name,
    required this.additives,
    required this.createdBy,
    required this.shareCode,
    required this.shareCount,
    required this.isPublic,
    required this.pricePerKg,
    required this.expiryDays,
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
    expiryDays,
    createdAt,
    updatedAt,
  ];
}
