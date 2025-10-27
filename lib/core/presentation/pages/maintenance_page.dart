import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_bloc.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_event.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_state.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  bool _isChecking = false;

  void _checkStatus() {
    setState(() {
      _isChecking = true;
    });

    // Trigger the app settings check
    context.read<AppSettingsBloc>().add(const LoadAppSettings());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AppSettingsBloc, AppSettingsState>(
      listener: (context, state) {
        if (state is AppSettingsLoaded) {
          setState(() {
            _isChecking = false;
          });

          // If maintenance mode is off, navigate to splash
          if (!state.settings.maintenanceMode) {
            context.go('/splash');
          } else {
            // Show a message that maintenance is still ongoing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Still under maintenance. Please check back later.',
                ),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        } else if (state is AppSettingsError) {
          setState(() {
            _isChecking = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to check status: ${state.message}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.construction_rounded,
                    size: 100,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Under Maintenance',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  BlocBuilder<AppSettingsBloc, AppSettingsState>(
                    builder: (context, state) {
                      String message =
                          'We\'re currently performing maintenance to improve your experience. Please check back later.';

                      if (state is AppSettingsLoaded &&
                          state.settings.maintenanceMessage.isNotEmpty) {
                        message = state.settings.maintenanceMessage;
                      }

                      return Text(
                        message,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Check Status Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isChecking ? null : _checkStatus,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(_isChecking ? 'Checking...' : 'Check Status'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Support Contact
                  BlocBuilder<AppSettingsBloc, AppSettingsState>(
                    builder: (context, state) {
                      if (state is AppSettingsLoaded) {
                        return Column(
                          children: [
                            Text(
                              'Need help?',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.settings.supportEmail,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
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
            ),
          ),
        ),
      ),
    );
  }
}
