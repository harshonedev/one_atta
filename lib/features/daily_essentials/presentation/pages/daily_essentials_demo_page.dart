import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DailyEssentialsDemoPage extends StatelessWidget {
  const DailyEssentialsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Essentials Demo'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Essentials Products',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Click on any product below to view its detailed page:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Product cards
            _buildProductCard(
              context,
              'Atta (Classic Wheat)',
              'Traditional whole wheat flour blend perfect for daily use',
              'atta_classic_wheat',
              Icons.grain,
              Colors.amber,
            ),
            const SizedBox(height: 16),

            _buildProductCard(
              context,
              'Bedmi',
              'Special spiced flour blend for authentic bedmi puri',
              'bedmi_flour',
              Icons.restaurant,
              Colors.deepOrange,
            ),
            const SizedBox(height: 16),

            _buildProductCard(
              context,
              'Missi',
              'Mixed gram and wheat flour blend rich in protein',
              'missi_flour',
              Icons.fitness_center,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String name,
    String description,
    String productId,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/daily-essential-details/$productId');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
