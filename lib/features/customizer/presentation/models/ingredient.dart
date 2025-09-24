import 'package:flutter/material.dart';
import 'package:one_atta/features/customizer/domain/entities/ingredient_entity.dart';

class Ingredient {
  final String id;
  final String name;
  double percentage;
  final NutritionalInfo? nutritionalInfo;
  final IconData icon;
  final GlobalKey rowKey = GlobalKey(); // For the whole row
  final GlobalKey iconKey = GlobalKey(); // Specifically for the icon

  Ingredient({
    required this.id,
    required this.name,
    required this.percentage,
    required this.icon,
    this.nutritionalInfo,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    double? percentage,
    IconData? icon,
    NutritionalInfo? nutritionalInfo,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      icon: icon ?? this.icon,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }
}
