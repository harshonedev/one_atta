import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_state.dart';

class SavedBlendsPage extends StatelessWidget {
  const SavedBlendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SavedBlendsBloc(repository: di.sl())..add(const LoadUserBlends()),
      child: const SavedBlendsView(),
    );
  }
}

class SavedBlendsView extends StatelessWidget {
  const SavedBlendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Blends'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Cart',
          ),
        ],
      ),
      body: BlocConsumer<SavedBlendsBloc, SavedBlendsState>(
        listener: (context, state) {
          if (state is SavedBlendsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SavedBlendsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SavedBlendsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is SavedBlendsLoaded) {
            return _buildBlendsContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/customizer');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Blend'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return ErrorPage(
      onRetry: () {
        context.read<SavedBlendsBloc>().add(const LoadUserBlends());
      },
    );
  }

  Widget _buildBlendsContent(BuildContext context, SavedBlendsLoaded state) {
    if (state.blends.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SavedBlendsBloc>().add(const RefreshUserBlends());
      },
      child: Column(
        children: [
          // Blends list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100), // Space for FAB
              itemCount: state.blends.length,
              itemBuilder: (context, index) {
                final blend = state.blends[index];
                return SavedBlendListCard(
                  blend: blend,
                  onTap: () {
                    context.push('/blend-details/${blend.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.blender_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Blends',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first custom blend to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.push('/customizer');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Blend'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display a saved blend in the list
class SavedBlendListCard extends StatelessWidget {
  final BlendEntity blend;
  final VoidCallback onTap;

  const SavedBlendListCard({
    super.key,
    required this.blend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blend.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${_formatDate(blend.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ingredients: ${blend.additives.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: blend.isPublic
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      blend.isPublic ? 'Public' : 'Private',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: blend.isPublic
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${blend.pricePerKg.toStringAsFixed(2)}/kg',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
