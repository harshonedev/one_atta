import 'package:equatable/equatable.dart';

abstract class BlendsEvent extends Equatable {
  const BlendsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPublicBlends extends BlendsEvent {
  const LoadPublicBlends();
}

class RefreshBlends extends BlendsEvent {
  const RefreshBlends();
}


