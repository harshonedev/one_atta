import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/app_settings/domain/repositories/app_settings_repository.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_event.dart';
import 'package:one_atta/features/app_settings/presentation/bloc/app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final AppSettingsRepository appSettingsRepository;

  AppSettingsBloc({required this.appSettingsRepository})
    : super(AppSettingsInitial()) {
    on<LoadAppSettings>(_onLoadAppSettings);
  }

  Future<void> _onLoadAppSettings(
    LoadAppSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    emit(AppSettingsLoading());

    final result = await appSettingsRepository.getAppSettings();

    result.fold(
      (failure) => emit(AppSettingsError(failure.message)),
      (settings) => emit(AppSettingsLoaded(settings)),
    );
  }
}
