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
}
