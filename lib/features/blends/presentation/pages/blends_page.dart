import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/blends/presentation/bloc/blends_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/blends_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/blends_state.dart';
import '../widgets/blend_list_card.dart';

class BlendsPage extends StatelessWidget {
  const BlendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BlendsBloc(repository: di.sl())..add(const LoadPublicBlends()),
      child: const BlendsView(),
    );
  }
}

class BlendsView extends StatelessWidget {
  const BlendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Our Blends'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showShareCodeDialog(context),
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'Find by Share Code',
          ),
        ],
      ),
      body: BlocConsumer<BlendsBloc, BlendsState>(
        listener: (context, state) {
          if (state is BlendShared) {
            _showShareDialog(context, state.shareCode);
          } else if (state is BlendSubscribed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Successfully subscribed to blend!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is BlendActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is BlendByShareCodeLoaded) {
            // Navigate to blend details
            context.push('/blend-details/${state.blend.id}');
          }
        },
        builder: (context, state) {
          if (state is BlendsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BlendsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is BlendsLoaded) {
            return _buildBlendsContent(context, state);
          }

          if (state is BlendActionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create blend page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create blend feature coming soon!')),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Blend'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return ErrorPage(
      onRetry: () {
        context.read<BlendsBloc>().add(const LoadPublicBlends());
      },
    );
  }

  Widget _buildBlendsContent(BuildContext context, BlendsLoaded state) {
    if (state.blends.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BlendsBloc>().add(const RefreshBlends());
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
                return BlendListCard(
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
        child: Text(
          'No Blends Available',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, String shareCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Blend Shared'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with others:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shareCode,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareCode));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share code copied!')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showShareCodeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Find Blend by Share Code',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter share code',
            hintText: 'e.g., ABC1234',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final shareCode = controller.text.trim();
              if (shareCode.isNotEmpty) {
                Navigator.of(context).pop();
                context.read<BlendsBloc>().add(GetBlendByShareCode(shareCode));
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }
}
