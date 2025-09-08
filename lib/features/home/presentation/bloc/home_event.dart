import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class SearchBlends extends HomeEvent {
  final String query;

  const SearchBlends(this.query);

  @override
  List<Object> get props => [query];
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class LoadTrendingBlends extends HomeEvent {
  const LoadTrendingBlends();
}

class LoadFeaturedRecipes extends HomeEvent {
  const LoadFeaturedRecipes();
}

class LoadUserProfile extends HomeEvent {
  const LoadUserProfile();
}
