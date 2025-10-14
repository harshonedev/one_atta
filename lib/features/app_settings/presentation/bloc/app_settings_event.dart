import 'package:equatable/equatable.dart';

abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppSettings extends AppSettingsEvent {
  const LoadAppSettings();
}
