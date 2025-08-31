import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/presentation/pages/splash_page.dart';
import 'package:one_atta/core/presentation/pages/main_navigation_page.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';
import 'package:one_atta/features/auth/presentation/pages/login_page.dart';
import 'package:one_atta/features/auth/presentation/pages/register_page.dart';
import 'package:one_atta/features/auth/presentation/pages/otp_page.dart';
import 'package:one_atta/features/auth/presentation/pages/onboarding_page.dart';
import 'package:one_atta/features/recipes/presentation/pages/recipe_details_page.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_bloc.dart';

class AppRouter {
  static late final GoRouter _router;

  static GoRouter get router => _router;

  static void init() {
    _router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        // Get the auth bloc to check authentication state
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;

        final isOnSplash = state.fullPath == '/splash';
        final isOnOnboarding = state.fullPath == '/onboarding';
        final isOnAuth =
            state.fullPath == '/login' ||
            state.fullPath == '/register' ||
            state.fullPath == '/otp' ||
            state.fullPath == '/forgot-password';

        // If user is authenticated and trying to access auth/onboarding pages, redirect to home
        if (authState is AuthAuthenticated && (isOnAuth || isOnOnboarding)) {
          return '/home';
        }

        // If user is not authenticated and trying to access protected pages, redirect to onboarding
        if (authState is AuthUnauthenticated &&
            !isOnAuth &&
            !isOnSplash &&
            !isOnOnboarding) {
          return '/onboarding';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/otp',
          name: 'otp',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>? ?? {};
            return OtpPage(data: data);
          },
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const MainNavigationPage(),
        ),
        GoRoute(
          path: '/recipe-details/:recipeId',
          name: 'recipe-details',
          builder: (context, state) {
            final recipeId = state.pathParameters['recipeId']!;
            return BlocProvider(
              create: (context) => RecipeDetailsBloc(),
              child: RecipeDetailsPage(recipeId: recipeId),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
