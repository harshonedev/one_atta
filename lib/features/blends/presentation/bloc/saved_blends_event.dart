import 'package:equatable/equatable.dart';

abstract class SavedBlendsEvent extends Equatable {
  const SavedBlendsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserBlends extends SavedBlendsEvent {
  const LoadUserBlends();
}

class RefreshUserBlends extends SavedBlendsEvent {
  const RefreshUserBlends();
}
