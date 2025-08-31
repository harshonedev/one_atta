import 'package:flutter/material.dart';

class NetworkImageLoader extends StatelessWidget {
  final String imageUrl;
  final BorderRadius? borderRadius;
  final double height;
  final double width;
  final BoxFit fit;
  const NetworkImageLoader({
    super.key,
    required this.imageUrl,
    this.borderRadius,
    required this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Icon(
              Icons.blender_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
