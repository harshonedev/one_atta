import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_event.dart';
import 'package:one_atta/features/blends/presentation/bloc/saved_blends_state.dart';

class SavedBlendsBloc extends Bloc<SavedBlendsEvent, SavedBlendsState> {
  final BlendsRepository _repository;

  SavedBlendsBloc({required BlendsRepository repository})
    : _repository = repository,
      super(const SavedBlendsInitial()) {
    on<LoadUserBlends>(_onLoadUserBlends);
    on<RefreshUserBlends>(_onRefreshUserBlends);
  }

  Future<void> _onLoadUserBlends(
    LoadUserBlends event,
    Emitter<SavedBlendsState> emit,
  ) async {
    emit(const SavedBlendsLoading());

    final result = await _repository.getUserBlends();

    result.fold(
      (failure) => emit(SavedBlendsError(failure.message)),
      (blends) => emit(SavedBlendsLoaded(blends)),
    );
  }

  Future<void> _onRefreshUserBlends(
    RefreshUserBlends event,
    Emitter<SavedBlendsState> emit,
  ) async {
    // Don't show loading indicator for refresh
    final result = await _repository.getUserBlends();

    result.fold(
      (failure) => emit(SavedBlendsError(failure.message)),
      (blends) => emit(SavedBlendsLoaded(blends)),
    );
  }
}
