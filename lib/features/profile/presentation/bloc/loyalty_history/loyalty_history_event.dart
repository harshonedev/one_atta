import 'package:equatable/equatable.dart';

abstract class LoyaltyHistoryEvent extends Equatable {
  const LoyaltyHistoryEvent();

  @override
  List<Object?> get props => [];
}

class GetLoyaltyHistoryRequested extends LoyaltyHistoryEvent {
  const GetLoyaltyHistoryRequested();
}

class RefreshLoyaltyHistoryRequested extends LoyaltyHistoryEvent {
  const RefreshLoyaltyHistoryRequested();
}

class ClearLoyaltyHistoryCacheRequested extends LoyaltyHistoryEvent {
  const ClearLoyaltyHistoryCacheRequested();
}

class FilterLoyaltyHistoryRequested extends LoyaltyHistoryEvent {
  final String? filterType; // 'earning', 'redemption', null for all
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterLoyaltyHistoryRequested({
    this.filterType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [filterType, startDate, endDate];
}
