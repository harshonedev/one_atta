import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_share_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/blend_share_state.dart';

class BlendShareBloc extends Bloc<BlendShareEvent, BlendShareState> {
  final BlendsRepository _repository;

  BlendShareBloc({required BlendsRepository repository})
    : _repository = repository,
      super(const BlendShareInitial()) {
    on<LoadBlendByShareCode>(_onLoadBlendByShareCode);
    on<RefreshBlendByShareCode>(_onRefreshBlendByShareCode);
  }

  Future<void> _onLoadBlendByShareCode(
    LoadBlendByShareCode event,
    Emitter<BlendShareState> emit,
  ) async {
    emit(const BlendShareLoading());

    final result = await _repository.getBlendByShareCode(event.shareCode);

    result.fold(
      (failure) => emit(BlendShareError(failure.message, failure: failure)),
      (blend) => emit(BlendShareLoaded(blend)),
    );
  }

  Future<void> _onRefreshBlendByShareCode(
    RefreshBlendByShareCode event,
    Emitter<BlendShareState> emit,
  ) async {
    // Don't show loading indicator for refresh
    final result = await _repository.getBlendByShareCode(event.shareCode);

    result.fold(
      (failure) => emit(BlendShareError(failure.message, failure: failure)),
      (blend) => emit(BlendShareLoaded(blend)),
    );
  }
}
