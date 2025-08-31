import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final void Function()? onRetry;
  const ErrorPage({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Something went wrong!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Try Again Button
            FilledButton(
              onPressed: () {
                if (onRetry != null) {
                  onRetry!();
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
