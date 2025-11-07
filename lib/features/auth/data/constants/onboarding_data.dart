import 'package:flutter/material.dart';
import 'package:one_atta/features/auth/domain/entities/onboarding_content_entity.dart';

/// Static data for walkthrough/onboarding screens
/// This shows new users the key features of the One Atta app
class OnboardingData {
  static const List<OnboardingContentEntity> walkthroughScreens = [
    OnboardingContentEntity(
      title: 'Create Custom Atta Blends',
      description:
          'Mix and match different grains to create your perfect atta blend. Control nutritional values and customize ratios to suit your dietary needs.',
      icon: Icons.tune_rounded,
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ),
    OnboardingContentEntity(
      title: 'Browse Pre-Made Blends',
      description:
          'Explore our curated collection of expertly crafted flour blends. From multigrain to ragi, find the perfect blend for your recipes.',
      icon: Icons.inventory_2_rounded,
      gradientColors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    ),
    OnboardingContentEntity(
      title: 'Discover Delicious Recipes',
      description:
          'Get inspired with hundreds of recipes specially designed for our flour blends. Step-by-step instructions with video guides.',
      icon: Icons.restaurant_menu_rounded,
      gradientColors: [Color(0xFFEE5A6F), Color(0xFFF29263)],
    ),
    OnboardingContentEntity(
      title: 'Watch Recipe Play',
      description:
          'Learn cooking techniques through short, engaging video Play. Follow along with expert chefs and home cooks.',
      icon: Icons.video_library_rounded,
      gradientColors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    ),
    OnboardingContentEntity(
      title: 'Earn Atta Points',
      description:
          'Get rewarded for every purchase! Earn Atta Points, share blends, review products, and redeem points for discounts on future orders.',
      icon: Icons.card_giftcard_rounded,
      gradientColors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
    ),
  ];

  /// Get the list of walkthrough screens
  static List<OnboardingContentEntity> getWalkthroughScreens() {
    return walkthroughScreens;
  }

  /// Get a specific walkthrough screen by index
  static OnboardingContentEntity getWalkthroughScreen(int index) {
    if (index >= 0 && index < walkthroughScreens.length) {
      return walkthroughScreens[index];
    }
    throw RangeError('Index $index is out of range for walkthrough screens');
  }

  /// Get the total number of walkthrough screens
  static int get totalScreens => walkthroughScreens.length;
}
