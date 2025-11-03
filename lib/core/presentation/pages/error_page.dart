import 'package:flutter/material.dart';
import 'package:one_atta/core/error/failures.dart';

class ErrorPage extends StatelessWidget {
  final String? message;
  final Failure? failure;
  final void Function()? onRetry;

  const ErrorPage({super.key, this.message, this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(errorInfo.icon, size: 80, color: errorInfo.color),
            const SizedBox(height: 24),

            // Error Title
            Text(
              errorInfo.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Error Message
            Text(
              errorInfo.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Try Again Button
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ErrorInfo _getErrorInfo() {
    // Check if we have a specific failure type
    if (failure != null) {
      if (failure is NetworkFailure) {
        return _ErrorInfo(
          icon: Icons.wifi_off_rounded,
          title: 'No Internet Connection',
          description: failure!.message.isNotEmpty
              ? failure!.message
              : 'Please check your internet connection and try again.',
          color: Colors.orange,
        );
      } else if (failure is ServerFailure) {
        return _ErrorInfo(
          icon: Icons.cloud_off_rounded,
          title: 'Server Error',
          description: failure!.message.isNotEmpty
              ? failure!.message
              : 'We\'re having trouble connecting to our servers. Please try again later.',
          color: Colors.red,
        );
      } else if (failure is UnauthorizedFailure) {
        return _ErrorInfo(
          icon: Icons.lock_outline_rounded,
          title: 'Unauthorized Access',
          description: failure!.message.isNotEmpty
              ? failure!.message
              : 'You don\'t have permission to access this resource.',
          color: Colors.deepOrange,
        );
      } else if (failure is ValidationFailure) {
        return _ErrorInfo(
          icon: Icons.warning_amber_rounded,
          title: 'Validation Error',
          description: failure!.message.isNotEmpty
              ? failure!.message
              : 'The information provided is invalid.',
          color: Colors.amber,
        );
      } else if (failure is CacheFailure) {
        return _ErrorInfo(
          icon: Icons.storage_rounded,
          title: 'Storage Error',
          description: failure!.message.isNotEmpty
              ? failure!.message
              : 'There was a problem accessing local storage.',
          color: Colors.purple,
        );
      } else if (failure is NotFoundFailure) {
        return _ErrorInfo(
          icon: Icons.search_off_rounded,
          title: 'Not Found',
          description: failure!.message.isNotEmpty
              ? failure!.message
              : 'The requested resource could not be found.',
          color: Colors.blueGrey,
        );
      }
    }

    // Default error with custom message
    return _ErrorInfo(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong!',
      description: message ?? 'An unexpected error occurred. Please try again.',
      color: Colors.red,
    );
  }
}

class _ErrorInfo {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _ErrorInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
