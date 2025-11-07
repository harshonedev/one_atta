import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/services/preferences_service.dart';

class WalkthroughCubit extends Cubit<bool> {
  final PreferencesService _preferencesService;
  WalkthroughCubit(this._preferencesService) : super(false);

  Future<void> checkWalkthroughSeen() async {
    try {
      final hasSeen = await _preferencesService.hasSeenWalkthrough();
      emit(hasSeen);
    } catch (e) {
      emit(false);
    }
  }
}
