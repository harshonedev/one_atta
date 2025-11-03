import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/daily_essentials/domain/entities/daily_essential_entity.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_bloc.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_event.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_state.dart';

class DailyEssentialsListPage extends StatelessWidget {
  const DailyEssentialsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Essentials'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: BlocBuilder<DailyEssentialsBloc, DailyEssentialsState>(
        builder: (context, state) {
          if (state is DailyEssentialsInitial) {
            // Trigger initial load
            context.read<DailyEssentialsBloc>().add(const LoadAllProducts());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailyEssentialsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailyEssentialsError) {
            return ErrorPage(
              failure: state.failure,
              onRetry: () {
                context.read<DailyEssentialsBloc>().add(
                  const LoadAllProducts(),
                );
              },
            );
          }

          if (state is DailyEssentialsLoaded) {
            if (state.products.isEmpty) {
              return _buildEmptyView(context);
            }

            return _buildProductList(
              context,
              state.products,
              state.isRefreshing,
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }


  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new products',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    List<DailyEssentialEntity> products,
    bool isRefreshing,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DailyEssentialsBloc>().add(const RefreshProducts());
      },
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    context.push('/daily-essential-details/${product.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product.imageUrls.isNotEmpty
                                  ? Image.network(
                                      product.imageUrls.first,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildImagePlaceholder(
                                              context,
                                            );
                                          },
                                    )
                                  : _buildImagePlaceholder(context),
                            ),
                            const SizedBox(width: 16),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${product.price.toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '/${product.unit}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const Spacer(),
                                      if (product.hasDiscount) ...[
                                        Text(
                                          '₹${product.originalPrice.toStringAsFixed(0)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Category and stock status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.category,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              !product.isInStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: product.isInStock
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.shopping_basket_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
