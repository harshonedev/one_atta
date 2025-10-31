import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/blends/presentation/bloc/blends_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/blends_state.dart';

class BlendsBloc extends Bloc<BlendsEvent, BlendsState> {
  final BlendsRepository _repository;

  BlendsBloc({required BlendsRepository repository})
    : _repository = repository,
      super(const BlendsInitial()) {
    on<LoadPublicBlends>(_onLoadPublicBlends);
    on<RefreshBlends>(_onRefreshBlends);
  }

  Future<void> _onLoadPublicBlends(
    LoadPublicBlends event,
    Emitter<BlendsState> emit,
  ) async {
    emit(const BlendsLoading());

    final result = await _repository.getAllPublicBlends();

    result.fold(
      (failure) => emit(BlendsError(failure.message)),
      (blends) => emit(BlendsLoaded(blends)),
    );
  }

  Future<void> _onRefreshBlends(
    RefreshBlends event,
    Emitter<BlendsState> emit,
  ) async {
    // Don't show loading indicator for refresh
    final result = await _repository.getAllPublicBlends();

    result.fold(
      (failure) => emit(BlendsError(failure.message)),
      (blends) => emit(BlendsLoaded(blends)),
    );
  }
}
