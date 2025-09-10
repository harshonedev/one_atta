import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/daily_essentials/domain/entities/daily_essential_entity.dart';
import 'package:one_atta/features/daily_essentials/presentation/widgets/image_carousel.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_event.dart';
import 'package:share_plus/share_plus.dart';

class DailyEssentialDetailsPage extends StatefulWidget {
  final String productId;

  const DailyEssentialDetailsPage({super.key, required this.productId});

  @override
  State<DailyEssentialDetailsPage> createState() =>
      _DailyEssentialDetailsPageState();
}

class _DailyEssentialDetailsPageState extends State<DailyEssentialDetailsPage> {
  int _quantity = 1;
  bool _isLoading = false;

  // Static data for now
  late DailyEssentialEntity _product;

  @override
  void initState() {
    super.initState();
    _loadStaticData();
  }

  void _loadStaticData() {
    // Dynamic data based on the 3 D2C products from home page
    switch (widget.productId) {
      case 'atta_classic_wheat':
        _product = const DailyEssentialEntity(
          id: 'atta_classic_wheat',
          name: 'Atta (Classic Wheat)',
          description:
              'Traditional whole wheat flour blend perfect for daily use. Made from finest quality wheat grains, stone-ground to preserve nutrients and authentic taste. Ideal for rotis, parathas, and everyday bread making.',
          imageUrls: [
            'https://images.unsplash.com/photo-1627735483792-233bf632619b?w=800',
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
            'https://images.unsplash.com/photo-1574323567620-09824068bb90?w=800',
          ],
          category: 'Classic',
          price: 50.0,
          originalPrice: 60.0,
          unit: 'kg',
          stockQuantity: 100,
          isInStock: true,
          tags: ['Traditional', 'Whole Wheat', 'Daily Use', 'Stone Ground'],
          benefits: [
            'Rich in dietary fiber for digestive health',
            'High protein content for muscle strength',
            'Contains essential vitamins and minerals',
            'Natural source of complex carbohydrates',
            'Supports healthy weight management',
          ],
          brand: 'OneAtta',
          origin: 'Punjab, India',
          expiryInfo: 'Best before 6 months from packaging',
          rating: 4.7,
          reviewCount: 342,
          isOrganic: false,
          nutritionalInfo: {
            'Protein': '12g per 100g',
            'Fat': '1.5g per 100g',
            'Carbs': '71g per 100g',
            'Fiber': '11g per 100g',
            'Calories': '348 per 100g',
          },
          storageInstructions:
              'Store in a cool, dry place in an airtight container.',
        );
        break;
      case 'bedmi_flour':
        _product = const DailyEssentialEntity(
          id: 'bedmi_flour',
          name: 'Bedmi',
          description:
              'Special spiced flour blend for authentic bedmi puri. Traditional recipe with carefully selected spices and lentils. Perfect for making crispy, flavorful bedmi puris that pair excellently with aloo sabzi.',
          imageUrls: [
            'https://images.unsplash.com/photo-1710857389305-5cba9211033f?w=800',
            'https://images.unsplash.com/photo-1571197119282-621b4d4f4096?w=800',
            'https://images.unsplash.com/photo-1606471191009-63da133b49bb?w=800',
          ],
          category: 'Special',
          price: 70.0,
          originalPrice: 80.0,
          unit: 'kg',
          stockQuantity: 75,
          isInStock: true,
          tags: ['Spiced', 'Traditional', 'Authentic', 'Lentils'],
          benefits: [
            'Enhanced flavor with traditional spices',
            'Rich in plant-based protein from lentils',
            'Authentic taste of traditional recipes',
            'Balanced nutrition from mixed grains',
            'Natural digestive properties from spices',
          ],
          brand: 'OneAtta',
          origin: 'Uttar Pradesh, India',
          expiryInfo: 'Best before 4 months from packaging',
          rating: 4.6,
          reviewCount: 187,
          isOrganic: false,
          nutritionalInfo: {
            'Protein': '15g per 100g',
            'Fat': '2.8g per 100g',
            'Carbs': '68g per 100g',
            'Fiber': '13g per 100g',
            'Calories': '356 per 100g',
          },
          storageInstructions:
              'Store in a cool, dry place away from moisture and strong odors.',
        );
        break;
      case 'missi_flour':
        _product = const DailyEssentialEntity(
          id: 'missi_flour',
          name: 'Missi',
          description:
              'Mixed gram and wheat flour blend rich in protein. Perfect combination of wheat flour and gram flour (besan) creating nutritious and delicious missi rotis. High protein content makes it ideal for health-conscious families.',
          imageUrls: [
            'https://images.unsplash.com/photo-1704650311974-8ce378f0e8b0?w=800',
            'https://images.unsplash.com/photo-1558618047-b72c9d58fccd?w=800',
            'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=800',
          ],
          category: 'Protein',
          price: 80.0,
          originalPrice: 90.0,
          unit: 'kg',
          stockQuantity: 85,
          isInStock: true,
          tags: ['Gram', 'Wheat', 'High Protein', 'Nutritious'],
          benefits: [
            'High protein content from gram flour',
            'Balanced amino acid profile',
            'Rich in folate and iron',
            'Supports muscle health and growth',
            'Lower glycemic index than regular wheat',
          ],
          brand: 'OneAtta',
          origin: 'Rajasthan, India',
          expiryInfo: 'Best before 5 months from packaging',
          rating: 4.8,
          reviewCount: 259,
          isOrganic: false,
          nutritionalInfo: {
            'Protein': '18g per 100g',
            'Fat': '3.2g per 100g',
            'Carbs': '65g per 100g',
            'Fiber': '15g per 100g',
            'Calories': '372 per 100g',
          },
          storageInstructions:
              'Store in an airtight container in a cool, dry place to maintain freshness.',
        );
        break;
      default:
        // Fallback to Atta Classic Wheat
        _product = const DailyEssentialEntity(
          id: 'atta_classic_wheat',
          name: 'Atta (Classic Wheat)',
          description:
              'Traditional whole wheat flour blend perfect for daily use. Made from finest quality wheat grains, stone-ground to preserve nutrients and authentic taste.',
          imageUrls: [
            'https://images.unsplash.com/photo-1627735483792-233bf632619b?w=800',
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
            'https://images.unsplash.com/photo-1574323567620-09824068bb90?w=800',
          ],
          category: 'Classic',
          price: 50.0,
          originalPrice: 60.0,
          unit: 'kg',
          stockQuantity: 100,
          isInStock: true,
          tags: ['Traditional', 'Whole Wheat', 'Daily Use'],
          benefits: [
            'Rich in dietary fiber for digestive health',
            'High protein content for muscle strength',
            'Contains essential vitamins and minerals',
            'Natural source of complex carbohydrates',
          ],
          brand: 'OneAtta',
          origin: 'Punjab, India',
          expiryInfo: 'Best before 6 months from packaging',
          rating: 4.7,
          reviewCount: 342,
          isOrganic: false,
          nutritionalInfo: {
            'Protein': '12g per 100g',
            'Fat': '1.5g per 100g',
            'Carbs': '71g per 100g',
            'Fiber': '11g per 100g',
            'Calories': '348 per 100g',
          },
          storageInstructions:
              'Store in a cool, dry place in an airtight container.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App bar with image carousel
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: BackButton(color: Theme.of(context).colorScheme.onSurface),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(
                imageUrls: _product.imageUrls,
                height: 350,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Check out this amazing product: ${_product.name}',
                        subject: 'Daily Essential - ${_product.name}',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Product details content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge and organic badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _product.category,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (_product.isOrganic) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 14,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Organic',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Product name
                      Text(
                        _product.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      // Brand and rating
                      Row(
                        children: [
                          Text(
                            'by ${_product.brand}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_product.rating}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                ' (${_product.reviewCount} reviews)',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price section
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '₹${_product.price.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                  Text(
                                    ' /${_product.unit}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                              if (_product.hasDiscount) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '₹${_product.originalPrice.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${_product.discountPercentage.toStringAsFixed(0)}% OFF',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stock status
                      Row(
                        children: [
                          Icon(
                            _product.isInStock
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: _product.isInStock
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _product.isInStock
                                ? 'In Stock (${_product.stockQuantity} available)'
                                : 'Out of Stock',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _product.isInStock
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Description
                _buildSection(
                  context,
                  'Description',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _product.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _product.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Benefits section
                _buildSection(
                  context,
                  'Health Benefits',
                  Column(
                    children: _product.benefits.map((benefit) {
                      return _buildBenefitItem(context, benefit);
                    }).toList(),
                  ),
                ),

                // Nutritional Information
                _buildSection(
                  context,
                  'Nutritional Information',
                  Column(
                    children: _product.nutritionalInfo.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Origin and Storage
                _buildSection(
                  context,
                  'Product Details',
                  Column(
                    children: [
                      _buildDetailRow(context, 'Origin', _product.origin),
                      _buildDetailRow(
                        context,
                        'Storage',
                        _product.storageInstructions,
                      ),
                      _buildDetailRow(context, 'Expiry', _product.expiryInfo),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(benefit, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < _product.stockQuantity
                        ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Add to cart button
            Expanded(
              child: FilledButton.icon(
                onPressed: _product.isInStock && !_isLoading
                    ? () => _addToCart(context)
                    : null,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(
                  _product.isInStock
                      ? 'Add to Cart - ₹${(_product.price * _quantity).toStringAsFixed(0)}'
                      : 'Out of Stock',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Add to cart
        final cartItem = CartItemEntity(
          productId: _product.id,
          productName: _product.name,
          productType: 'daily_essential',
          quantity: _quantity,
          price: _product.price,
          imageUrl: _product.imageUrls.first,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.read<CartBloc>().add(AddItemToCart(item: cartItem));

        // Show success feedback
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_product.name} added to cart!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onPrimary.withOpacity(0.1),
              onPressed: () {
                context.push('/cart');
              },
            ),
          ),
        );
      }
    });
  }
}
