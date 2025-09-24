import 'package:equatable/equatable.dart';
import 'package:one_atta/features/blends/domain/entities/blend_entity.dart';

abstract class SavedBlendsState extends Equatable {
  const SavedBlendsState();

  @override
  List<Object?> get props => [];
}

class SavedBlendsInitial extends SavedBlendsState {
  const SavedBlendsInitial();
}

class SavedBlendsLoading extends SavedBlendsState {
  const SavedBlendsLoading();
}

class SavedBlendsLoaded extends SavedBlendsState {
  final List<BlendEntity> blends;

  const SavedBlendsLoaded(this.blends);

  @override
  List<Object?> get props => [blends];
}

class SavedBlendsError extends SavedBlendsState {
  final String message;

  const SavedBlendsError(this.message);

  @override
  List<Object?> get props => [message];
}
