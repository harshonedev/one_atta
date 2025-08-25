import 'package:equatable/equatable.dart';

// Models for home page data
class BlendItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;
  final List<String> tags;

  const BlendItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.tags,
  });

  @override
  List<Object> get props => [
    id,
    name,
    description,
    imageUrl,
    rating,
    category,
    tags,
  ];
}

class RecipeItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int cookingTime;
  final String difficulty;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const RecipeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  @override
  List<Object> get props => [
    id,
    name,
    description,
    imageUrl,
    cookingTime,
    difficulty,
    rating,
    reviewCount,
    tags,
  ];
}

class UserProfile extends Equatable {
  final String name;
  final int grainPoints;

  const UserProfile({required this.name, required this.grainPoints});

  @override
  List<Object> get props => [name, grainPoints];
}
