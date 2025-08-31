import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/di/injection_container.dart' as di;
import 'package:one_atta/core/routing/app_router.dart';
import 'package:one_atta/core/theme/theme.dart';
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => RecipesBloc()),
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
