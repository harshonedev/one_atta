import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check authentication status
    //context.read<AuthBloc>().add(AuthCheckRequested());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(seconds: 2), () {
        context.go('/onboarding');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // if (state is AuthAuthenticated) {
        //   // User is logged in, navigate to home
        //   context.go('/home');
        // } else if (state is AuthUnauthenticated) {
        //   // User is not logged in, navigate to onboarding
        //   context.go('/onboarding');
        // }
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: AspectRatio(
            aspectRatio: 376 / 58,
            child: Center(child: Image.asset(AppAssets.logo)),
          ),
        ),
      ),
    );
  }
}
