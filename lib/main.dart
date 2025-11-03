import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/routing/app_router.dart';
import 'package:one_atta/core/services/notification_service.dart';
import 'package:one_atta/core/theme/theme.dart';
import 'package:one_atta/features/address/presentation/bloc/address_event.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_event.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_share_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_bloc.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_history/loyalty_history_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_bloc.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';
import 'package:one_atta/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:one_atta/features/cart/data/datasources/cart_hive_data_source_impl.dart';
import 'package:one_atta/features/reels/data/datasources/reels_local_data_source_impl.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_event.dart';
import 'package:one_atta/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:one_atta/features/orders/presentation/bloc/order_bloc.dart';
import 'package:one_atta/features/faq/presentation/bloc/faq_bloc.dart';
import 'package:one_atta/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_bloc.dart';
import 'package:one_atta/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:one_atta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:one_atta/core/services/fcm_service.dart';
import 'package:one_atta/core/services/preferences_service.dart';
import 'package:one_atta/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await CartHiveDataSourceImpl.initHive();
  await ReelsLocalDataSourceImpl.initHive();

  // Initialize dependency injection
  await di.init();

  // Initialize router
  AppRouter.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM
  await di.sl<FCMService>().initialize();

  // Set preferences service for FCM
  final fcmService = di.sl<FCMService>();
  fcmService.setPreferencesService(di.sl<PreferencesService>());

  // register FCM token
  await di.sl<NotificationService>().registerFcmToken();

  // Set up FCM token auto-update
  fcmService.onTokenUpdated = (String newToken) {
    // Auto-update token when it changes
    di.sl<NotificationBloc>().add(UpdateFcmToken(newToken));
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<HomeBloc>()),
        BlocProvider(create: (context) => di.sl<RecipesBloc>()),
        BlocProvider(create: (context) => di.sl<RecipeDetailsBloc>()),
        BlocProvider(create: (context) => di.sl<CustomizerBloc>()),
        BlocProvider(create: (context) => di.sl<SavedBlendsBloc>()),
        BlocProvider(create: (context) => di.sl<CartBloc>()),
        BlocProvider(create: (context) => di.sl<LoyaltyBloc>()),
        BlocProvider(create: (context) => di.sl<LoyaltyHistoryBloc>()),
        BlocProvider(create: (context) => di.sl<DailyEssentialsBloc>()),
        BlocProvider(create: (context) => di.sl<BlendShareBloc>()),
        BlocProvider(
          create: (context) => di.sl<AddressBloc>()..add(LoadAddresses()),
        ),
        BlocProvider(create: (context) => di.sl<CouponBloc>()),
        BlocProvider(
          create: (context) =>
              di.sl<UserProfileBloc>()..add(const GetUserProfileRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<ReelsBloc>()..add(const LoadReelsFeed()),
        ),
        BlocProvider(create: (context) => di.sl<PaymentBloc>()),
        BlocProvider(create: (context) => di.sl<OrderBloc>()),
        BlocProvider(create: (context) => di.sl<DeliveryBloc>()),
        BlocProvider(create: (context) => di.sl<FaqBloc>()),
        BlocProvider(create: (context) => di.sl<FeedbackBloc>()),
        BlocProvider(
          create: (context) => di.sl<AppSettingsBloc>()..add(LoadAppSettings()),
        ),
        BlocProvider(create: (context) => di.sl<ContactBloc>()),
        BlocProvider(
          create: (context) =>
              di.sl<NotificationBloc>()..add(const LoadNotifications()),
        ),
      ],
      child: MaterialApp.router(
        title: 'One Atta',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().light(),
        darkTheme: AppTheme().dark(),
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
