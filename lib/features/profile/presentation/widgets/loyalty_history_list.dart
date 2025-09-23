import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:one_atta/features/profile/presentation/widgets/loyalty_transaction_card.dart';

class LoyaltyHistoryList extends StatelessWidget {
  const LoyaltyHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<LoyaltyHistoryBloc, LoyaltyHistoryState>(
      builder: (context, state) {
        if (state is LoyaltyHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LoyaltyHistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<LoyaltyHistoryBloc>().add(
                    const GetLoyaltyHistoryRequested(),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is LoyaltyHistoryLoaded) {
          if (state.filteredTransactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No loyalty transactions found.',
                  style: textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = state.filteredTransactions[index];
              return LoyaltyTransactionCard(transaction: transaction);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
