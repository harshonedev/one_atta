import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Entity representing a single onboarding screen content
class OnboardingContentEntity extends Equatable {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String? imagePath;

  const OnboardingContentEntity({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    icon,
    gradientColors,
    imagePath,
  ];
}
