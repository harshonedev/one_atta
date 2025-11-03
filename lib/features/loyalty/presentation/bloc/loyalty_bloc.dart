import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_event.dart';
import 'package:one_atta/features/loyalty/presentation/bloc/loyalty_state.dart';

class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final LoyaltyRepository loyaltyRepository;
  LoyaltyBloc({required this.loyaltyRepository}) : super(LoyaltyInitial()) {
    on<FetchLoyaltySettings>(_onFetchLoyaltySettings);
  }

  Future<void> _onFetchLoyaltySettings(
    FetchLoyaltySettings event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(LoyaltyInitial());
    final result = await loyaltyRepository.getLoyaltySettings();
    result.fold(
      (failure) {
        emit(LoyaltyError(message: failure.message, failure: failure));
      },
      (loyaltySettings) {
        emit(LoyaltySettingsLoaded(loyaltySettingsEntity: loyaltySettings));
      },
    );
  }
}
