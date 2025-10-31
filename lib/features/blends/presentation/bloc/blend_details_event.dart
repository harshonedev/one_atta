import 'package:equatable/equatable.dart';

abstract class BlendDetailsEvent extends Equatable {
  const BlendDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBlendDetails extends BlendDetailsEvent {
  final String blendId;

  const LoadBlendDetails(this.blendId);

  @override
  List<Object?> get props => [blendId];
}

class RefreshBlendDetails extends BlendDetailsEvent {
  final String blendId;

  const RefreshBlendDetails(this.blendId);

  @override
  List<Object?> get props => [blendId];
}

