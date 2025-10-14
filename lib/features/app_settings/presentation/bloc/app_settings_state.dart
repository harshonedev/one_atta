import 'package:equatable/equatable.dart';
import 'package:one_atta/features/app_settings/domain/entities/app_settings_entity.dart';

abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object?> get props => [];
}

class AppSettingsInitial extends AppSettingsState {}

class AppSettingsLoading extends AppSettingsState {}

class AppSettingsLoaded extends AppSettingsState {
  final AppSettingsEntity settings;

  const AppSettingsLoaded(this.settings);

  @override
  List<Object> get props => [settings];
}

class AppSettingsError extends AppSettingsState {
  final String message;

  const AppSettingsError(this.message);

  @override
  List<Object> get props => [message];
}
