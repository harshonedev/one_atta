import 'package:equatable/equatable.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';

abstract class BlendsState extends Equatable {
  const BlendsState();

  @override
  List<Object?> get props => [];
}

class BlendsInitial extends BlendsState {
  const BlendsInitial();
}

class BlendsLoading extends BlendsState {
  const BlendsLoading();
}

class BlendsLoaded extends BlendsState {
  final List<PublicBlendEntity> blends;

  const BlendsLoaded(this.blends);

  @override
  List<Object?> get props => [blends];
}

class BlendsError extends BlendsState {
  final String message;

  const BlendsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BlendShared extends BlendsState {
  final String shareCode;

  const BlendShared(this.shareCode);

  @override
  List<Object?> get props => [shareCode];
}

class BlendSubscribed extends BlendsState {
  const BlendSubscribed();
}

class BlendByShareCodeLoaded extends BlendsState {
  final PublicBlendEntity blend;

  const BlendByShareCodeLoaded(this.blend);

  @override
  List<Object?> get props => [blend];
}

class BlendActionLoading extends BlendsState {
  const BlendActionLoading();
}

class BlendActionError extends BlendsState {
  final String message;

  const BlendActionError(this.message);

  @override
  List<Object?> get props => [message];
}
