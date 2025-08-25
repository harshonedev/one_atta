import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const OtpPage({super.key, required this.data});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _resendTime = 30;
  bool _canResend = false;

  String get phoneNumber => widget.data['phoneNumber'] ?? '';
  bool get isFromRegister => widget.data['isFromRegister'] ?? false;
  String get name => widget.data['name'] ?? '';
  String get email => widget.data['email'] ?? '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTime = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTime == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendTime--;
        });
      }
    });
  }

  void _resendOtp() {
    if (_canResend) {
      _startResendTimer();
      // Here you would trigger the resend OTP logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent successfully')));
    }
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      // Simulate OTP verification
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length >= 10) {
      final start = phone.substring(0, phone.length - 6);
      final end = phone.substring(phone.length - 2);
      return '${start}XXXXXX$end';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    32,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                    // Main content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),

                              // Enter OTP title
                              Text(
                                'Enter OTP',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 16),

                              // Subtitle with phone number
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          "We've sent a one-time password to ",
                                    ),
                                    TextSpan(
                                      text: _formatPhoneNumber(phoneNumber),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 48),

                              // OTP Input Fields
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  6,
                                  (index) => SizedBox(
                                    width: 45,
                                    height: 60,
                                    child: TextFormField(
                                      controller: _otpControllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                            width: 2,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          _onOtpChanged(value, index),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Resend OTP
                              Center(
                                child: _canResend
                                    ? TextButton(
                                        onPressed: _resendOtp,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        child: Text(
                                          'Resend OTP',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Resend OTP in 00:${_resendTime.toString().padLeft(2, '0')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                              ),

                              const Spacer(),

                              // Verify & Continue Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return FilledButton(
                                    onPressed: state is AuthLoading
                                        ? null
                                        : _verifyOtp,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      minimumSize: const Size(
                                        double.infinity,
                                        56,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: state is AuthLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Verify & Continue',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Wrong number link
                              Center(
                                child: TextButton(
                                  onPressed: () => context.pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  child: Text(
                                    'Wrong number? Edit',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
