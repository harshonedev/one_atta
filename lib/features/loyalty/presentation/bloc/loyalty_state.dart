import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/loyalty/domain/entities/loyalty_settings_entity.dart';

abstract class LoyaltyState extends Equatable {}

class LoyaltyInitial extends LoyaltyState {
  @override
  List<Object?> get props => [];
}

class LoyaltySettingsLoaded extends LoyaltyState {
  final LoyaltySettingsEntity loyaltySettingsEntity;

  LoyaltySettingsLoaded({required this.loyaltySettingsEntity});

  @override
  List<Object?> get props => [loyaltySettingsEntity];
}

class LoyaltyError extends LoyaltyState {
  final String message;
  final Failure? failure;

  LoyaltyError({required this.message, this.failure});

  @override
  List<Object?> get props => [message, failure];
}
