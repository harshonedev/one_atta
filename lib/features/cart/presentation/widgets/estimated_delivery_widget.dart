import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_state.dart';

class EstimatedDeliveryWidget extends StatelessWidget {
  const EstimatedDeliveryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color onSurfaceVariant = Theme.of(
      context,
    ).colorScheme.onSurfaceVariant;

    return BlocBuilder<DeliveryBloc, DeliveryState>(
      buildWhen: (previous, current) => current is DeliveryLoaded,
      builder: (context, state) {
        final estimatedTime = (state is DeliveryLoaded)
            ? state.etaDisplay
            : '2-3';
        final DateTime now = DateTime.now();
        final DateTime maxDate = now.add(
          Duration(
            days: (state is DeliveryLoaded)
                ? (state.maxEta > 0 ? state.maxEta : 3)
                : 3,
          ),
        );
        final formatMaxDate = DateFormat('d MMM').format(maxDate);
        final String maxDateStr =
            "Your order will be deliver at $formatMaxDate";

        print('Current State: ${state.runtimeType}');
        print('Estimated Delivery Time: $estimatedTime days');
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Delivery: $estimatedTime',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        maxDateStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
