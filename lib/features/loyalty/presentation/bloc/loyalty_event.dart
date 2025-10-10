import 'package:equatable/equatable.dart';

abstract class LoyaltyEvent extends Equatable {}

class FetchLoyaltySettings extends LoyaltyEvent {
  @override
  List<Object?> get props => [];
}
