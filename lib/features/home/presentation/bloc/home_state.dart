import 'package:equatable/equatable.dart';
import 'home_models.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final UserProfile userProfile;
  final List<BlendItem> readyToSellBlends;
  final List<BlendItem> trendingBlends;
  final List<RecipeItem> recipes;

  const HomeLoaded({
    required this.userProfile,
    required this.readyToSellBlends,
    required this.trendingBlends,
    required this.recipes,
  });

  @override
  List<Object> get props => [
    userProfile,
    readyToSellBlends,
    trendingBlends,
    recipes,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
