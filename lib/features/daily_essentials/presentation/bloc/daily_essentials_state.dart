import 'package:equatable/equatable.dart';
import 'package:one_atta/features/daily_essentials/domain/entities/daily_essential_entity.dart';

abstract class DailyEssentialsState extends Equatable {
  const DailyEssentialsState();

  @override
  List<Object?> get props => [];
}

class DailyEssentialsInitial extends DailyEssentialsState {
  const DailyEssentialsInitial();
}

class DailyEssentialsLoading extends DailyEssentialsState {
  const DailyEssentialsLoading();
}

class DailyEssentialsLoaded extends DailyEssentialsState {
  final List<DailyEssentialEntity> products;
  final bool isRefreshing;

  const DailyEssentialsLoaded({
    required this.products,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [products, isRefreshing];

  DailyEssentialsLoaded copyWith({
    List<DailyEssentialEntity>? products,
    bool? isRefreshing,
  }) {
    return DailyEssentialsLoaded(
      products: products ?? this.products,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class DailyEssentialsError extends DailyEssentialsState {
  final String message;

  const DailyEssentialsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductDetailLoading extends DailyEssentialsState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends DailyEssentialsState {
  final DailyEssentialEntity product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends DailyEssentialsState {
  final String message;

  const ProductDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
