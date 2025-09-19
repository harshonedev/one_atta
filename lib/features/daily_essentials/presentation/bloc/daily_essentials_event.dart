import 'package:equatable/equatable.dart';

abstract class DailyEssentialsEvent extends Equatable {
  const DailyEssentialsEvent();

  @override
  List<Object> get props => [];
}

class LoadAllProducts extends DailyEssentialsEvent {
  final bool? isSeasonal;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortOrder;
  final int? page;
  final int? limit;

  const LoadAllProducts({
    this.isSeasonal,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortOrder,
    this.page,
    this.limit,
  });

  @override
  List<Object> get props => [
    isSeasonal ?? '',
    search ?? '',
    minPrice ?? '',
    maxPrice ?? '',
    sortBy ?? '',
    sortOrder ?? '',
    page ?? '',
    limit ?? '',
  ];
}

class LoadProductById extends DailyEssentialsEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshProducts extends DailyEssentialsEvent {
  const RefreshProducts();
}
