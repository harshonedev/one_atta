import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 300.0,
    this.borderRadius,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    if (widget.imageUrls.length == 1) {
      return _buildSingleImage(widget.imageUrls.first);
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Image PageView
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return _buildImage(widget.imageUrls[index]);
              },
            ),
          ),

          // Page Indicators
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: SizedBox(height: widget.height, child: _buildImage(imageUrl)),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: widget.height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: widget.height,
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
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_basket_outlined,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
