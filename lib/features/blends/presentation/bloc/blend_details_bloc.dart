import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_details_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_details_state.dart';

class BlendDetailsBloc extends Bloc<BlendDetailsEvent, BlendDetailsState> {
  final BlendsRepository _repository;

  BlendDetailsBloc({required BlendsRepository repository})
    : _repository = repository,
      super(const BlendDetailsInitial()) {
    on<LoadBlendDetails>(_onLoadBlendDetails);
    on<RefreshBlendDetails>(_onRefreshBlendDetails);
    on<ShareBlendFromDetails>(_onShareBlendFromDetails);
    on<SubscribeToBlendFromDetails>(_onSubscribeToBlendFromDetails);
    on<UpdateBlendDetails>(_onUpdateBlendDetails);
  }

  Future<void> _onLoadBlendDetails(
    LoadBlendDetails event,
    Emitter<BlendDetailsState> emit,
  ) async {
    emit(const BlendDetailsLoading());

    final result = await _repository.getBlendDetails(event.blendId);

    result.fold(
      (failure) => emit(BlendDetailsError(failure.message)),
      (blend) => emit(BlendDetailsLoaded(blend)),
    );
  }

  Future<void> _onRefreshBlendDetails(
    RefreshBlendDetails event,
    Emitter<BlendDetailsState> emit,
  ) async {
    // Don't show loading indicator for refresh
    final result = await _repository.getBlendDetails(event.blendId);

    result.fold(
      (failure) => emit(BlendDetailsError(failure.message)),
      (blend) => emit(BlendDetailsLoaded(blend)),
    );
  }

  Future<void> _onShareBlendFromDetails(
    ShareBlendFromDetails event,
    Emitter<BlendDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BlendDetailsLoaded) {
      emit(BlendDetailsActionLoading(currentState.blend));

      final result = await _repository.shareBlend(event.blendId);

      result.fold(
        (failure) =>
            emit(BlendDetailsActionError(currentState.blend, failure.message)),
        (shareCode) => emit(BlendDetailsShared(currentState.blend, shareCode)),
      );
    }
  }

  Future<void> _onSubscribeToBlendFromDetails(
    SubscribeToBlendFromDetails event,
    Emitter<BlendDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BlendDetailsLoaded) {
      emit(BlendDetailsActionLoading(currentState.blend));

      final result = await _repository.subscribeToBlend(event.blendId);

      result.fold(
        (failure) =>
            emit(BlendDetailsActionError(currentState.blend, failure.message)),
        (_) => emit(BlendDetailsSubscribed(currentState.blend)),
      );
    }
  }

  Future<void> _onUpdateBlendDetails(
    UpdateBlendDetails event,
    Emitter<BlendDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BlendDetailsLoaded) {
      emit(BlendDetailsActionLoading(currentState.blend));

      final result = await _repository.updateBlend(
        event.blendId,
        event.updateBlend,
      );

      result.fold(
        (failure) =>
            emit(BlendDetailsActionError(currentState.blend, failure.message)),
        (updatedBlend) => emit(BlendDetailsUpdated(updatedBlend)),
      );
    }
  }
}
