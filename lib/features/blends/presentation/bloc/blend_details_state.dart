import 'package:equatable/equatable.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';

abstract class BlendDetailsState extends Equatable {
  const BlendDetailsState();

  @override
  List<Object?> get props => [];
}

class BlendDetailsInitial extends BlendDetailsState {
  const BlendDetailsInitial();
}

class BlendDetailsLoading extends BlendDetailsState {
  const BlendDetailsLoading();
}

class BlendDetailsLoaded extends BlendDetailsState {
  final BlendDetailsEntity blend;

  const BlendDetailsLoaded(this.blend);

  @override
  List<Object?> get props => [blend];
}

class BlendDetailsError extends BlendDetailsState {
  final String message;

  const BlendDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BlendDetailsActionLoading extends BlendDetailsState {
  final BlendDetailsEntity blend;

  const BlendDetailsActionLoading(this.blend);

  @override
  List<Object?> get props => [blend];
}

class BlendDetailsShared extends BlendDetailsState {
  final BlendDetailsEntity blend;
  final String shareCode;

  const BlendDetailsShared(this.blend, this.shareCode);

  @override
  List<Object?> get props => [blend, shareCode];
}

class BlendDetailsSubscribed extends BlendDetailsState {
  final BlendDetailsEntity blend;

  const BlendDetailsSubscribed(this.blend);

  @override
  List<Object?> get props => [blend];
}

class BlendDetailsUpdated extends BlendDetailsState {
  final BlendEntity updatedBlend;

  const BlendDetailsUpdated(this.updatedBlend);

  @override
  List<Object?> get props => [updatedBlend];
}

class BlendDetailsActionError extends BlendDetailsState {
  final BlendDetailsEntity blend;
  final String message;

  const BlendDetailsActionError(this.blend, this.message);

  @override
  List<Object?> get props => [blend, message];
}
