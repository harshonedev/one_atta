class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int prepTime;
  final double rating;
  final String difficulty;
  final List<String> categories;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final Nutrition nutrition;
  final String? videoUrl;
  final bool isFeatured;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.prepTime,
    required this.rating,
    required this.difficulty,
    required this.categories,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    this.videoUrl,
    this.isFeatured = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      prepTime: json['prepTime'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      difficulty: json['difficulty'] ?? 'Easy',
      categories: List<String>.from(json['categories'] ?? []),
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e))
              .toList() ??
          [],
      instructions: List<String>.from(json['instructions'] ?? []),
      nutrition: Nutrition.fromJson(json['nutrition'] ?? {}),
      videoUrl: json['videoUrl'],
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'rating': rating,
      'difficulty': difficulty,
      'categories': categories,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'nutrition': nutrition.toJson(),
      'videoUrl': videoUrl,
      'isFeatured': isFeatured,
    };
  }
}

class Ingredient {
  final String name;
  final String quantity;

  Ingredient({required this.name, required this.quantity});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity};
  }
}

class Nutrition {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class CommunityMember {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;

  CommunityMember({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl, 'rating': rating};
  }
}
