import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/routing/app_router.dart';
import 'package:one_atta/core/theme/theme.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_bloc.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';
import 'package:one_atta/features/cart/data/datasources/cart_hive_data_source_impl.dart';
import 'package:one_atta/features/reels/data/datasources/reels_local_data_source_impl.dart';
import 'package:one_atta/features/profile/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_points/loyalty_points_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_history/loyalty_history_bloc.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await CartHiveDataSourceImpl.initHive();
  await ReelsLocalDataSourceImpl.initHive();

  // Initialize dependency injection
  await di.init();

  // Initialize router
  AppRouter.init();

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
        BlocProvider(create: (context) => di.sl<DailyEssentialsBloc>()),
        BlocProvider(create: (context) => di.sl<AddressBloc>()),
        BlocProvider(
          create: (context) =>
              di.sl<UserProfileBloc>()..add(const GetUserProfileRequested()),
        ),
        BlocProvider(create: (context) => di.sl<LoyaltyPointsBloc>()),
        BlocProvider(
          create: (context) =>
              di.sl<LoyaltyHistoryBloc>()
                ..add(const GetLoyaltyHistoryRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<ReelsBloc>()..add(const LoadReelsFeed()),
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
