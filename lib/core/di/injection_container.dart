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
