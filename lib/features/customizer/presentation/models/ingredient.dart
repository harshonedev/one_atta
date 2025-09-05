import 'package:flutter/material.dart';

class Ingredient {
  final String name;
  double percentage;
  final IconData icon;
  final GlobalKey rowKey = GlobalKey(); // For the whole row
  final GlobalKey iconKey = GlobalKey(); // Specifically for the icon

  Ingredient({
    required this.name,
    required this.percentage,
    required this.icon,
  });
}
