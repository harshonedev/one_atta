import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'package:one_atta/core/utils/snackbar_utils.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_event.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_state.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';

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
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserProfileBloc, UserProfileState>(
          listener: (context, state) {
            if (state is UserProfileLoaded) {
              // Navigate to home page after profile is loaded
              context.go('/home');
            } else if (state is UserProfileError) {
              // If there's an error loading profile, navigate to onboarding
              if (state.isAuthError) {
                // If error is due to authentication, log out the user
                context.read<AuthBloc>().add(AuthLogoutRequested());
                context.go('/onboarding');
                return;
              }

              if (state.isNetworkError) {
                // If error is due to network, show a snackbar and stay on splash
                SnackbarUtils.showWarning(
                  context,
                  "Network error. Please check your connection.",
                );
                return;
              }
              context.go('/home');
            }
          },
        ),

        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // User is logged in, navigate to home
              context.read<UserProfileBloc>().add(GetUserProfileRequested());
            } else if (state is AuthUnauthenticated) {
              // User is not logged in, navigate to onboarding
              context.go('/onboarding');
            }
          },
        ),
      ],
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
