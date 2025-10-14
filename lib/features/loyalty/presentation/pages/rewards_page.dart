import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_event.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_state.dart';
import 'package:one_atta/features/loyalty/presentation/widgets/transaction_card.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_event.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_state.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    context.read<LoyaltyBloc>().add(FetchLoyaltySettings());
    context.read<LoyaltyHistoryBloc>().add(const GetLoyaltyHistoryRequested());
    context.read<UserProfileBloc>().add(GetUserProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,

        title: Text(
          'Atta Rewards',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showRewardsInfoDialog(context),
            icon: const Icon(Icons.info_outline_rounded),
            color: colorScheme.onSurface,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _initializeData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Balance Section
              _buildPointsBalanceSection(context),

              // Earn Points Section
              _buildEarnPointsSection(context),

              // Transaction History Section
              _buildTransactionHistorySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsBalanceSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return _buildPointsCardSkeleton(context);
        }

        if (state is UserProfileError) {
          return _buildErrorCard(context, 'Failed to load points balance');
        }

        if (state is UserProfileLoaded) {
          final points = state.profile.loyaltyPoints;

          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.stars_rounded,
                      color: colorScheme.onPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Atta Points',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$points',
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<LoyaltyBloc, LoyaltyState>(
                          builder: (context, loyaltyState) {
                            if (loyaltyState is LoyaltySettingsLoaded) {
                              final value =
                                  (points *
                                          loyaltyState
                                              .loyaltySettingsEntity
                                              .pointValue)
                                      .toStringAsFixed(2);
                              return Text(
                                'Worth ₹$value',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEarnPointsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<LoyaltyBloc, LoyaltyState>(
      builder: (context, state) {
        if (state is LoyaltySettingsLoaded) {
          final settings = state.loyaltySettingsEntity;

          return Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Earn Atta Points',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Share Custom Blend Card
                if (settings.enableBlendShareRewards)
                  _buildEarnPointsCard(
                    context,
                    icon: Icons.share_rounded,
                    iconColor: Colors.purple,
                    title: 'Share Your Custom Blend',
                    description:
                        'Create and share your unique atta blend with others',
                    points: '${settings.sharePoints} Points',
                    onTap: () => _handleShareBlend(context),
                  ),

                const SizedBox(height: 8),

                // Review on Play Store Card
                if (settings.enableReviewRewards)
                  _buildEarnPointsCard(
                    context,
                    icon: Icons.star_rate_rounded,
                    iconColor: Colors.amber,
                    title: 'Review Us on Play Store',
                    description: 'Rate us 5 stars and mail us the screenshot',
                    points: '${settings.reviewPoints} Points',
                    onTap: () => _handleReviewPlayStore(context),
                  ),

                const SizedBox(height: 8),

                // Purchase Products Card
                if (settings.enableOrderRewards)
                  _buildEarnPointsCard(
                    context,
                    icon: Icons.shopping_cart_rounded,
                    iconColor: Colors.green,
                    title: 'Buy Products & Blends',
                    description:
                        'Earn ${settings.orderPercentForPoints}% of order value as points',
                    points: '${settings.orderPercentForPoints}% Back',
                    onTap: () => _handleShopNow(context),
                  ),
              ],
            ),
          );
        }

        if (state is LoyaltyError) {
          return _buildErrorCard(context, 'Failed to load earning options');
        }

        return _buildEarnPointsSkeleton(context);
      },
    );
  }

  Widget _buildEarnPointsCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String points,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                points,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistorySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Transaction History',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<LoyaltyHistoryBloc, LoyaltyHistoryState>(
            builder: (context, state) {
              if (state is LoyaltyHistoryLoading) {
                return _buildTransactionHistorySkeleton(context);
              }

              if (state is LoyaltyHistoryError) {
                return _buildErrorCard(
                  context,
                  'Failed to load transaction history',
                );
              }

              if (state is LoyaltyHistoryLoaded) {
                if (state.transactions.isEmpty) {
                  return _buildEmptyTransactionHistory(context);
                }

                return Column(
                  children: [
                    // Summary Stats
                    _buildTransactionSummary(context, state),
                    const SizedBox(height: 16),

                    // Transaction List
                    ...state.transactions
                        .take(10) // Show only latest 10 transactions
                        .map(
                          (transaction) =>
                              TransactionCard(transaction: transaction),
                        ),

                    if (state.transactions.length > 10)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TextButton(
                          onPressed: () => _showAllTransactions(context),
                          child: Text(
                            'View All Transactions',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary(
    BuildContext context,
    LoyaltyHistoryLoaded state,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${state.totalPointsEarned}',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Earned',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${state.totalPointsRedeemed}',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Redeemed',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactionHistory(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start earning points by shopping, sharing blends, or reviewing the app!',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Skeleton Loading Widgets
  Widget _buildPointsCardSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEarnPointsSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistorySkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: _initializeData,
            child: Text(
              'Retry',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Handlers
  void _handleShareBlend(BuildContext context) {
    // navigate to saved blends
    context.push('/saved-blends');
  }

  void _handleReviewPlayStore(BuildContext context) async {
    try {
      final uri = Uri.parse(AppConstants.playStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Play Store';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Play Store: $e')),
        );
      }
    }
  }

  void _handleShopNow(BuildContext context) {
    context.go('/home');
  }

  void _showAllTransactions(BuildContext context) {
    context.push('/transaction-history');
  }

  void _showRewardsInfoDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_rounded, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Rewards Info',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoPoint(
              context,
              '• Earn Atta Points by shopping, sharing blends, and reviewing our app',
            ),
            const SizedBox(height: 8),
            _buildInfoPoint(
              context,
              '• Redeem points during checkout for discounts on your orders',
            ),
            const SizedBox(height: 8),
            _buildInfoPoint(
              context,
              '• You cannot use coupons when redeeming Atta Points',
            ),
            const SizedBox(height: 8),
            _buildInfoPoint(
              context,
              '• Orders with redeemed points do not earn bonus percentage points',
            ),
            const SizedBox(height: 8),
            _buildInfoPoint(
              context,
              '• For Play Store reviews, rate us 5 stars and email the screenshot to earn points',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it!',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      text,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}
