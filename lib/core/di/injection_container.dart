import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/features/recipes/data/datasources/recipes_remote_data_source.dart';
import 'package:one_atta/features/recipes/data/datasources/recipes_remote_data_source_impl.dart';
import 'package:one_atta/features/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:one_atta/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipe_details_bloc.dart';
import 'package:one_atta/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// BLoC
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/blends_bloc.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_details_bloc.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';

// Data sources
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_data_source_impl.dart';

// Repository
import 'package:one_atta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

// Blends
import 'package:one_atta/features/blends/data/datasources/blends_remote_data_source.dart';
import 'package:one_atta/features/blends/data/datasources/blends_remote_data_source_impl.dart';
import 'package:one_atta/features/blends/data/repositories/blends_repository_impl.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';

// Customizer
import 'package:one_atta/features/customizer/data/datasources/customizer_remote_data_source.dart';
import 'package:one_atta/features/customizer/data/datasources/customizer_remote_data_source_impl.dart';
import 'package:one_atta/features/customizer/data/repositories/customizer_repository_impl.dart';
import 'package:one_atta/features/customizer/domain/repositories/customizer_repository.dart';

// Cart
import 'package:one_atta/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:one_atta/features/cart/data/datasources/cart_hive_data_source_impl.dart';
import 'package:one_atta/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:one_atta/features/cart/domain/repositories/cart_repository.dart';
import 'package:one_atta/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/get_cart_item_count_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:one_atta/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // BLoC
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Home
  // BLoC
  sl.registerFactory(
    () => HomeBloc(
      blendsRepository: sl(),
      recipesRepository: sl(),
      authRepository: sl(),
    ),
  );

  //! Features - Blends
  // BLoC
  sl.registerFactory(() => BlendsBloc(repository: sl()));
  sl.registerFactory(() => BlendDetailsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<BlendsRepository>(
    () =>
        BlendsRepositoryImpl(remoteDataSource: sl(), authLocalDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BlendsRemoteDataSource>(
    () => BlendsRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Customizer
  // BLoC
  sl.registerFactory(() => CustomizerBloc(customizerRepository: sl()));

  // Repository
  sl.registerLazySingleton<CustomizerRepository>(
    () => CustomizerRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CustomizerRemoteDataSource>(
    () => CustomizerRemoteDataSourceImpl(dio: sl(), authLocalDataSource: sl()),
  );

  //! Features - Cart
  // BLoC
  sl.registerFactory(
    () => CartBloc(
      getCartUseCase: sl(),
      addToCartUseCase: sl(),
      removeFromCartUseCase: sl(),
      updateCartItemQuantityUseCase: sl(),
      clearCartUseCase: sl(),
      getCartItemCountUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantityUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemCountUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CartLocalDataSource>(() => CartHiveDataSourceImpl());

  //! Core
  sl.registerLazySingleton(() => http.Client());

  // add api-key to the headers of Dio instance
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': AppConstants.appAPIKey,
        },
      ),
    ),
  );

  // Features - Recipes
  // BLoC
  sl.registerFactory(() => RecipesBloc(repository: sl()));
  sl.registerFactory(() => RecipeDetailsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<RecipesRepository>(
    () => RecipesRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<RecipesRemoteDataSource>(
    () => RecipesRemoteDataSourceImpl(dio: sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
