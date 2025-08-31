import 'package:equatable/equatable.dart';
import 'package:one_atta/features/blends/domain/entities/blend_request_entity.dart';

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

class ShareBlendFromDetails extends BlendDetailsEvent {
  final String blendId;

  const ShareBlendFromDetails(this.blendId);

  @override
  List<Object?> get props => [blendId];
}

class SubscribeToBlendFromDetails extends BlendDetailsEvent {
  final String blendId;

  const SubscribeToBlendFromDetails(this.blendId);

  @override
  List<Object?> get props => [blendId];
}

class UpdateBlendDetails extends BlendDetailsEvent {
  final String blendId;
  final UpdateBlendEntity updateBlend;

  const UpdateBlendDetails(this.blendId, this.updateBlend);

  @override
  List<Object?> get props => [blendId, updateBlend];
}
