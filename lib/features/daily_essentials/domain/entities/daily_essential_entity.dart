import 'package:equatable/equatable.dart';

class DailyEssentialEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls; // Multiple images for carousel
  final String category;
  final double price;
  final double originalPrice;
  final String unit; // kg, grams, pieces, etc.
  final int stockQuantity;
  final bool isInStock;
  final List<String> tags;
  final List<String> benefits;
  final String brand;
  final String origin;
  final String expiryInfo;
  final double rating;
  final int reviewCount;
  final bool isOrganic;
  final Map<String, String> nutritionalInfo;
  final String storageInstructions;

  const DailyEssentialEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.unit,
    required this.stockQuantity,
    required this.isInStock,
    required this.tags,
    required this.benefits,
    required this.brand,
    required this.origin,
    required this.expiryInfo,
    required this.rating,
    required this.reviewCount,
    required this.isOrganic,
    required this.nutritionalInfo,
    required this.storageInstructions,
  });

  double get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - price) / originalPrice) * 100;
  }

  bool get hasDiscount => originalPrice > price;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrls,
    category,
    price,
    originalPrice,
    unit,
    stockQuantity,
    isInStock,
    tags,
    benefits,
    brand,
    origin,
    expiryInfo,
    rating,
    reviewCount,
    isOrganic,
    nutritionalInfo,
    storageInstructions,
  ];
}
