import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Data sources
import 'package:one_atta/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:one_atta/features/auth/data/datasources/auth_remote_datasource.dart';

// Repositories
import 'package:one_atta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

// Use cases
import 'package:one_atta/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:one_atta/features/auth/domain/usecases/login_usecase.dart';
import 'package:one_atta/features/auth/domain/usecases/logout_usecase.dart';
import 'package:one_atta/features/auth/domain/usecases/register_usecase.dart';

// BLoC
import 'package:one_atta/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => http.Client());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
