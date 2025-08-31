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

class ShareBlend extends BlendsEvent {
  final String blendId;

  const ShareBlend(this.blendId);

  @override
  List<Object?> get props => [blendId];
}

class SubscribeToBlend extends BlendsEvent {
  final String blendId;

  const SubscribeToBlend(this.blendId);

  @override
  List<Object?> get props => [blendId];
}

class GetBlendByShareCode extends BlendsEvent {
  final String shareCode;

  const GetBlendByShareCode(this.shareCode);

  @override
  List<Object?> get props => [shareCode];
}
