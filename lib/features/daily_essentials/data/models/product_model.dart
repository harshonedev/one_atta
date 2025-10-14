import 'package:one_atta/features/daily_essentials/domain/entities/daily_essential_entity.dart';

class ProductModel extends DailyEssentialEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrls,
    required super.category,
    required super.price,
    required super.originalPrice,
    required super.unit,
    required super.stockQuantity,
    required super.isInStock,
    required super.tags,
    required super.benefits,
    required super.brand,
    required super.origin,
    required super.expiryInfo,
    required super.rating,
    required super.reviewCount,
    required super.isOrganic,
    required super.nutritionalInfo,
    required super.storageInstructions,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Map API response to our entity
    // Based on the product API docs, the API returns:
    // id, sku, name, description, isSeasonal, is_available, price_per_kg, prod_picture, nutritional_info, createdAt, updatedAt

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrls: json['prod_picture'] != null && json['prod_picture'].isNotEmpty
          ? [json['prod_picture']]
          : [],
      category: _determineCategoryFromName(json['name'] ?? ''),
      price: (json['price_per_kg'] ?? 0.0).toDouble(),
      originalPrice: (json['price_per_kg'] ?? 0.0)
          .toDouble(), // API doesn't have original price, so use same
      unit: 'kg', // Based on API, all products are per kg
      stockQuantity: 100, // Default stock as API doesn't provide this
      isInStock:!(json['outOfStock'] ?? false),
      tags: _generateTagsFromProduct(json),
      benefits: _generateBenefitsFromProduct(json),
      brand: 'OneAtta', // Default brand
      origin: 'India', // Default origin
      expiryInfo: 'Best before 6 months from packaging', // Default expiry info
      rating: 4.5, // Default rating as API doesn't provide this
      reviewCount: 50, // Default review count as API doesn't provide this
      isOrganic:
          json['isSeasonal'] ??
          false, // Use seasonal as organic indicator for now
      nutritionalInfo: _parseNutritionalInfo(json['nutritional_info']),
      storageInstructions:
          'Store in a cool, dry place in an airtight container.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'prod_picture': imageUrls.isNotEmpty ? imageUrls.first : null,
      'price_per_kg': price,
      'is_available': isInStock,
      'nutritional_info': nutritionalInfo,
    };
  }

  DailyEssentialEntity toEntity() => this;

  static String _determineCategoryFromName(String name) {
    final lowercaseName = name.toLowerCase();
    if (lowercaseName.contains('atta') || lowercaseName.contains('wheat')) {
      return 'Classic';
    } else if (lowercaseName.contains('bedmi')) {
      return 'Special';
    } else if (lowercaseName.contains('missi')) {
      return 'Premium';
    } else if (lowercaseName.contains('organic')) {
      return 'Organic';
    } else {
      return 'Classic';
    }
  }

  static List<String> _generateTagsFromProduct(Map<String, dynamic> json) {
    final tags = <String>[];
    final name = (json['name'] ?? '').toLowerCase();

    if (name.contains('wheat')) tags.add('Whole Wheat');
    if (name.contains('organic')) tags.add('Organic');
    if (name.contains('traditional')) tags.add('Traditional');
    if (json['isSeasonal'] == true) tags.add('Seasonal');
    if (name.contains('premium')) tags.add('Premium');
    if (name.contains('stone')) tags.add('Stone Ground');

    // Add default tags if none found
    if (tags.isEmpty) {
      tags.addAll(['Daily Use', 'Fresh']);
    }

    return tags;
  }

  static List<String> _generateBenefitsFromProduct(Map<String, dynamic> json) {
    // Generate benefits based on nutritional info if available
    final benefits = <String>[
      'Rich in dietary fiber for digestive health',
      'High protein content for muscle strength',
      'Contains essential vitamins and minerals',
    ];

    final nutritionalInfo = json['nutritional_info'] as Map<String, dynamic>?;
    if (nutritionalInfo != null) {
      if ((nutritionalInfo['protein'] ?? 0) > 10) {
        benefits.add('Excellent source of plant-based protein');
      }
      if ((nutritionalInfo['carbs'] ?? 0) > 60) {
        benefits.add('Natural source of complex carbohydrates');
      }
    }

    return benefits;
  }

  static Map<String, String> _parseNutritionalInfo(dynamic nutritionalInfo) {
    if (nutritionalInfo is Map<String, dynamic>) {
      final result = <String, String>{};

      nutritionalInfo.forEach((key, value) {
        if (value != null) {
          if (key == 'calories') {
            result[_formatNutritionalKey(key)] = '${value}cal';
            return;
          }
          result[_formatNutritionalKey(key)] = '${value}g';
        }
      });

      // Add default values if not present
      if (!result.containsKey('Calories')) {
        result['Calories'] = '350 per 100g';
      }

      return result;
    }

    // Return default nutritional info
    return {
      'Protein': '12g per 100g',
      'Fat': '1.5g per 100g',
      'Carbs': '71g per 100g',
      'Fiber': '11g per 100g',
      'Calories': '350 per 100g',
    };
  }

  static String _formatNutritionalKey(String key) {
    switch (key.toLowerCase()) {
      case 'protein':
        return 'Protein';
      case 'fat':
        return 'Fat';
      case 'carbs':
      case 'carbohydrates':
        return 'Carbs';
      case 'fiber':
      case 'fibre':
        return 'Fiber';
      case 'calories':
        return 'Calories';
      default:
        return key;
    }
  }
}
