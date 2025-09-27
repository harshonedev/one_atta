import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
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
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_bloc.dart';
import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';
import 'package:one_atta/features/customizer/domain/repositories/ingredient_repository.dart';
import 'package:one_atta/features/customizer/domain/usecases/get_ingredients.dart';
import 'package:one_atta/features/customizer/data/repositories/ingredient_repository_impl.dart';
import 'package:one_atta/features/home/presentation/bloc/home_bloc.dart';
import 'package:one_atta/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_bloc.dart';

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

// Daily Essentials
import 'package:one_atta/features/daily_essentials/data/datasources/daily_essentials_remote_data_source.dart';
import 'package:one_atta/features/daily_essentials/data/datasources/daily_essentials_remote_data_source_impl.dart';
import 'package:one_atta/features/daily_essentials/data/repositories/daily_essentials_repository_impl.dart';
import 'package:one_atta/features/daily_essentials/domain/repositories/daily_essentials_repository.dart';

// Address
import 'package:one_atta/features/address/data/datasources/address_remote_data_source.dart';
import 'package:one_atta/features/address/data/datasources/address_remote_data_source_impl.dart';
import 'package:one_atta/features/address/data/repositories/address_repository_impl.dart';
import 'package:one_atta/features/address/domain/repositories/address_repository.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';

// Profile
import 'package:one_atta/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:one_atta/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:one_atta/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:one_atta/features/profile/domain/repositories/profile_repository.dart';
// Profile - Updated BLoCs
import 'package:one_atta/features/profile/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_points/loyalty_points_bloc.dart';
import 'package:one_atta/features/profile/presentation/bloc/loyalty_history/loyalty_history_bloc.dart';

// Reels
import 'package:one_atta/features/reels/data/datasources/reels_local_data_source.dart';
import 'package:one_atta/features/reels/data/datasources/reels_local_data_source_impl.dart';
import 'package:one_atta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:one_atta/features/reels/data/datasources/reels_remote_data_source_impl.dart';
import 'package:one_atta/features/reels/data/repositories/reels_repository_impl.dart';
import 'package:one_atta/features/reels/domain/repositories/reels_repository.dart';
import 'package:one_atta/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:one_atta/core/services/video_cache_manager.dart';

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
    () => AuthRemoteDataSourceImpl(apiRequest: sl()),
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
      dailyEssentialsRepository: sl(),
    ),
  );

  //! Features - Blends
  // BLoC
  sl.registerFactory(() => BlendsBloc(repository: sl()));
  sl.registerFactory(() => BlendDetailsBloc(repository: sl()));
  sl.registerFactory(() => SavedBlendsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<BlendsRepository>(
    () =>
        BlendsRepositoryImpl(remoteDataSource: sl(), authLocalDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BlendsRemoteDataSource>(
    () => BlendsRemoteDataSourceImpl(apiRequest: sl()),
  );

  //! Features - Customizer
  // BLoC
  sl.registerFactory(
    () => CustomizerBloc(
      customizerRepository: sl(),
      getIngredientsUseCase: sl(),
      blendsRepository: sl(),
      authRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetIngredientsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CustomizerRepository>(
    () => CustomizerRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<IngredientRepository>(
    () => IngredientRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CustomizerRemoteDataSource>(
    () => CustomizerRemoteDataSourceImpl(
      apiRequest: sl(),
      authLocalDataSource: sl(),
    ),
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

  //! Features - Daily Essentials
  // BLoC
  sl.registerFactory(() => DailyEssentialsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<DailyEssentialsRepository>(
    () => DailyEssentialsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DailyEssentialsRemoteDataSource>(
    () => DailyEssentialsRemoteDataSourceImpl(apiRequest: sl()),
  );

  //! Features - Address
  // BLoC
  sl.registerFactory(
    () => AddressBloc(
      repository: sl<AddressRepository>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(apiRequest: sl()),
  );

  //! Features - Profile
  // BLoCs - Specialized for better separation of concerns
  sl.registerFactory(() => UserProfileBloc(profileRepository: sl()));
  sl.registerFactory(() => LoyaltyPointsBloc(profileRepository: sl()));
  sl.registerFactory(() => LoyaltyHistoryBloc(profileRepository: sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiRequest: sl()),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Reels
  // BLoC
  sl.registerFactory(() => ReelsBloc(reelsRepository: sl()));

  // Repository
  sl.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authLocalDataSource: sl(),
      videoCacheManager: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(apiRequest: sl()),
  );

  sl.registerLazySingleton<ReelsLocalDataSource>(
    () => ReelsLocalDataSourceImpl(),
  );

  // Services
  sl.registerLazySingleton<VideoCacheManager>(() {
    final cacheManager = VideoCacheManager.instance;
    cacheManager.init(); // Initialize the cache manager
    return cacheManager;
  });

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
    () => RecipesRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RecipesRemoteDataSource>(
    () => RecipesRemoteDataSourceImpl(apiRequest: sl()),
  );

  // API Request
  sl.registerLazySingleton(() => ApiRequest(dio: sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
