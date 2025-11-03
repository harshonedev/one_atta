import 'package:equatable/equatable.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';

abstract class BlendShareState extends Equatable {
  const BlendShareState();

  @override
  List<Object?> get props => [];
}

class BlendShareInitial extends BlendShareState {
  const BlendShareInitial();
}

class BlendShareLoading extends BlendShareState {
  const BlendShareLoading();
}

class BlendShareLoaded extends BlendShareState {
  final BlendDetailsEntity blend;

  const BlendShareLoaded(this.blend);

  @override
  List<Object?> get props => [blend];
}

class BlendShareError extends BlendShareState {
  final String message;
  final Failure failure;

  const BlendShareError(this.message, {required this.failure});

  @override
  List<Object?> get props => [message, failure];
}


