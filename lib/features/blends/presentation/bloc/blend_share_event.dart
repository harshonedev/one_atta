import 'package:equatable/equatable.dart';

abstract class BlendShareEvent extends Equatable {
  const BlendShareEvent();

  @override
  List<Object?> get props => [];
}

class LoadBlendByShareCode extends BlendShareEvent {
  final String shareCode;

  const LoadBlendByShareCode(this.shareCode);

  @override
  List<Object?> get props => [shareCode];
}

class RefreshBlendByShareCode extends BlendShareEvent {
  final String shareCode;

  const RefreshBlendByShareCode(this.shareCode);

  @override
  List<Object?> get props => [shareCode];
}
