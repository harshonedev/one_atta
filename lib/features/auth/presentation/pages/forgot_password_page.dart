import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/utils/validators.dart';
import 'package:one_atta/features/auth/domain/entities/auth_credentials.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_event.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';
import 'package:one_atta/features/auth/presentation/widgets/custom_button.dart';
import 'package:one_atta/features/auth/presentation/widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    if (_formKey.currentState!.validate()) {
      final credentials = ForgotPasswordCredentials(
        email: _emailController.text.trim(),
      );
      context.read<AuthBloc>().add(
        AuthForgotPasswordRequested(credentials: credentials),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Optionally navigate back after showing success
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) context.pop();
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    AppStrings.resetPassword,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!EmailValidator.isValid(value)) {
                        return AppStrings.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Send Reset Link Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: AppStrings.sendResetLink,
                        onPressed: _handleForgotPassword,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const Spacer(),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Remember your password?'),
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(AppStrings.signIn),
                      ),
                    ],
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
