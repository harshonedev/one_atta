class BlendImages {
  static const List<String> images = [
    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop', // Flour in wooden bowl
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop', // Wheat grains
    'https://images.unsplash.com/photo-1628968434281-89d31bb9c38c?w=400&h=300&fit=crop', // Various grains
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=300&fit=crop', // Quinoa and grains
    'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=300&fit=crop', // Oats in bowl
    'https://images.unsplash.com/photo-1559181567-c3190ca9959b?w=400&h=300&fit=crop', // Rice grains
    'https://images.unsplash.com/photo-1571167134814-b936ee33a29d?w=400&h=300&fit=crop', // Millet
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=300&fit=crop', // Mixed grains
    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop', // Whole wheat flour
    'https://images.unsplash.com/photo-1605027990121-cbae9e0642df?w=400&h=300&fit=crop', // Barley
    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop', // Buckwheat
    'https://images.unsplash.com/photo-1580393462641-a2d65fc4ca4b?w=400&h=300&fit=crop', // Rye grains
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=300&fit=crop', // Ancient grains mix
    'https://images.unsplash.com/photo-1605027990121-cbae9e0642df?w=400&h=300&fit=crop', // Amaranth
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop', // Spelt wheat
    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop', // Corn flour
    'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=300&fit=crop', // Rolled oats
    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=300&fit=crop', // Multi-grain blend
    'https://images.unsplash.com/photo-1559181567-c3190ca9959b?w=400&h=300&fit=crop', // Brown rice
    'https://images.unsplash.com/photo-1571167134814-b936ee33a29d?w=400&h=300&fit=crop', // Finger millet
  ];

  /// Get a random image for a blend based on its ID
  static String getImageForBlend(String blendId) {
    final hash = blendId.hashCode;
    final index = hash.abs() % images.length;
    return images[index];
  }
}
