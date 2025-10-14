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
import 'package:one_atta/features/loyalty/presentation/pages/rewards_page.dart';
import 'package:one_atta/features/loyalty/presentation/pages/transaction_history_page.dart';
import 'package:one_atta/features/payment/data/models/order_model.dart';
import 'package:one_atta/features/payment/domain/entities/order_data.dart';
import 'package:one_atta/features/recipes/presentation/pages/recipe_details_page.dart';
import 'package:one_atta/features/blends/presentation/pages/blends_page.dart';
import 'package:one_atta/features/blends/presentation/pages/blend_details_page.dart';
import 'package:one_atta/features/blends/presentation/pages/saved_blends_page.dart';
import 'package:one_atta/features/customizer/presentation/pages/customizer_page.dart';
import 'package:one_atta/features/customizer/presentation/pages/analysis_page.dart';
import 'package:one_atta/features/home/presentation/pages/home_page.dart';
import 'package:one_atta/features/orders/presentation/pages/orders_page.dart';
import 'package:one_atta/features/reels/presentation/pages/reels_page.dart';
import 'package:one_atta/features/recipes/presentation/pages/recipes_page.dart';
import 'package:one_atta/features/recipes/presentation/pages/liked_recipes_page.dart';
import 'package:one_atta/features/more/presentation/pages/more_page.dart';
import 'package:one_atta/features/cart/presentation/pages/cart_page.dart';
import 'package:one_atta/features/daily_essentials/presentation/pages/daily_essential_details_page.dart';
import 'package:one_atta/features/daily_essentials/presentation/pages/daily_essentials_list_page.dart';
import 'package:one_atta/features/address/presentation/pages/addresses_list_page.dart';
import 'package:one_atta/features/address/presentation/pages/add_edit_address_page.dart';
import 'package:one_atta/features/profile/presentation/pages/profile_page.dart';
import 'package:one_atta/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:one_atta/features/payment/presentation/pages/payment_method_selection_page.dart';
import 'package:one_atta/features/payment/presentation/pages/payment_process_page.dart';
import 'package:one_atta/features/payment/domain/entities/order_entity.dart';
import 'package:one_atta/features/payment/domain/entities/razorpay_details_entity.dart';
import 'package:one_atta/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:one_atta/features/orders/presentation/pages/order_detail_page.dart';

class AppRouter {
  static late final GoRouter _router;
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static void init() {
    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
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
        // ShellRoute for bottom navigation to keep the BottomNavigationBar persistent
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainNavigationPage(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/orders',
              name: 'orders',
              builder: (context, state) => const OrdersPage(),
            ),
            GoRoute(
              path: '/reels',
              name: 'reels',
              builder: (context, state) => const ReelsPage(),
            ),
            GoRoute(
              path: '/recipes',
              name: 'recipes',
              builder: (context, state) => const RecipesPage(),
            ),
            GoRoute(
              path: '/more',
              name: 'more',
              builder: (context, state) => const MorePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/recipe-details/:recipeId',
          name: 'recipe-details',
          builder: (context, state) {
            final recipeId = state.pathParameters['recipeId']!;
            return RecipeDetailsPage(recipeId: recipeId);
          },
        ),
        GoRoute(
          path: '/blends',
          name: 'blends',
          builder: (context, state) => const BlendsPage(),
        ),
        GoRoute(
          path: '/blend-details/:blendId',
          name: 'blend-details',
          builder: (context, state) {
            final blendId = state.pathParameters['blendId']!;
            return BlendDetailsPage(blendId: blendId);
          },
        ),
        GoRoute(
          path: '/saved-blends',
          name: 'saved-blends',
          builder: (context, state) => const SavedBlendsPage(),
        ),
        GoRoute(
          path: '/customizer',
          name: 'customizer',
          builder: (context, state) => const CustomizerPage(),
        ),
        GoRoute(
          path: '/analysis',
          name: 'analysis',
          builder: (context, state) => const AnalysisPage(),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/daily-essential-details/:productId',
          name: 'daily-essential-details',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return DailyEssentialDetailsPage(productId: productId);
          },
        ),
        GoRoute(
          path: '/daily-essentials-demo',
          name: 'daily-essentials-demo',
          builder: (context, state) => const DailyEssentialsListPage(),
        ),
        GoRoute(
          path: '/daily-essentials-list',
          name: 'daily-essentials-list',
          builder: (context, state) => const DailyEssentialsListPage(),
        ),
        GoRoute(
          path: '/liked-recipes',
          name: 'liked-recipes',
          builder: (context, state) => const LikedRecipesPage(),
        ),
        GoRoute(
          path: '/addresses',
          name: 'addresses',
          builder: (context, state) => const AddressesListPage(),
        ),
        GoRoute(
          path: '/address/add',
          name: 'add-address',
          builder: (context, state) => const AddEditAddressPage(),
        ),
        GoRoute(
          path: '/address/edit/:addressId',
          name: 'edit-address',
          builder: (context, state) {
            final addressId = state.pathParameters['addressId']!;
            return AddEditAddressPage(addressId: addressId);
          },
        ),
        GoRoute(
          path: '/rewards',
          name: 'rewards',
          builder: (context, state) => const RewardsPage(),
        ),
        GoRoute(
          path: '/transaction-history',
          name: 'transaction-history',
          builder: (context, state) => const TransactionHistoryPage(),
        ),

        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/profile/edit',
          name: 'edit-profile',
          builder: (context, state) => const EditProfilePage(),
        ),
        // Payment Routes
        GoRoute(
          path: '/payment/methods',
          name: 'payment-methods',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final orderData = extra['orderData'] as OrderData?;
            final amount = extra['amount'] as double? ?? 0.0;

            // Create a temporary order ID for payment flow
            final tempOrderId = DateTime.now().millisecondsSinceEpoch
                .toString();

            return PaymentMethodSelectionPage(
              orderId: tempOrderId,
              amount: amount,
              orderData: orderData,
            );
          },
        ),
        GoRoute(
          path: '/payment/process',
          name: 'payment-process',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final order = extra['order'] as OrderEntity;
            final razorpay = extra['razorpay'] as RazorpayDetailsEntity;

            return PaymentProcessPage(order: order, razorpay: razorpay);
          },
        ),
        GoRoute(
          path: '/order/confirmation',
          name: 'order-confirmation',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final orderJson = extra['order'] as Map<String, dynamic>?;

            if (orderJson == null) {
              // Fallback if order is not provided
              return const Scaffold(
                body: Center(child: Text('Order information not available')),
              );
            }

            final order = OrderModel.fromJson(orderJson).toEntity();
            return OrderConfirmationPage(order: order);
          },
        ),
        GoRoute(
          path: '/order-details/:orderId',
          name: 'order-details',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderDetailPage(orderId: orderId);
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
