import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_state.dart';
import 'package:one_atta/features/notifications/domain/entities/notification_entity.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                context.read<NotificationBloc>().add(
                  const MarkAllNotificationsAsRead(),
                );
              } else if (value == 'clear_all') {
                _showClearAllDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
            ],
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            SnackbarUtils.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  return _NotificationCard(
                    notification: state.notifications[index],
                    onTap: () {
                      if (!state.notifications[index].isRead) {
                        context.read<NotificationBloc>().add(
                          MarkNotificationAsRead(state.notifications[index].id),
                        );
                      }
                      _handleNotificationTap(
                        context,
                        state.notifications[index],
                      );
                    },
                    onDismissed: () {
                      context.read<NotificationBloc>().add(
                        DeleteNotification(state.notifications[index].id),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something arrives',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NotificationBloc>().add(
                const ClearAllNotifications(),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // Don't navigate if there's no data or if it would navigate to notifications
    if (notification.data == null || notification.data!.isEmpty) {
      return; // Just mark as read, don't navigate
    }

    final action = notification.data?['action'] as String?;

    if (action == null) {
      return; // Just mark as read, don't navigate
    }

    // Handle navigation based on action type, but skip if it's notifications-related
    switch (action.toLowerCase()) {
      case 'view_order':
      case 'order_update':
      case 'order_delivered':
      case 'order_cancelled':
        final orderId =
            notification.data?['order_id'] as String? ??
            notification.data?['orderId'] as String?;
        if (orderId != null) {
          context.push('/order-details/$orderId');
        } else {
          context.push('/orders');
        }
        break;

      case 'loyalty_points_earned':
      case 'blend_share_points_earned':
        context.push('/rewards');
        break;

      case 'view_expiring_items':
        context.push('/expiring-items');
        break;

      case 'general':
      case 'announcement':
      case 'promotional':
        // These are informational notifications, don't navigate
        return;

      default:
        // For unknown actions, don't navigate
        return;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'order':
        iconData = Icons.shopping_bag;
        iconColor = Colors.green;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case 'delivery':
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Theme.of(context).primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
