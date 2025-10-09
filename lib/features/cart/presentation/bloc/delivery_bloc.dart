import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/cart/domain/services/delivery_service.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_event.dart';
import 'package:one_atta/features/cart/presentation/bloc/delivery_state.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryService deliveryService;

  DeliveryBloc({required this.deliveryService}) : super(DeliveryInitial()) {
    on<CheckDeliveryAvailability>(_onCheckDeliveryAvailability);
  }

  Future<void> _onCheckDeliveryAvailability(
    CheckDeliveryAvailability event,
    Emitter<DeliveryState> emit,
  ) async {
    emit(DeliveryLoading());

    final result = await deliveryService.checkDeliveryAvailability(
      pincode: event.pincode,
      orderValue: event.orderValue,
      weight: event.weight,
      isExpress: event.isExpress,
    );

    result.fold(
      (failure) =>
          emit(DeliveryError(message: failure.message, pincode: event.pincode)),
      (deliveryInfo) {
        if (deliveryInfo == null) {
          emit(DeliveryNotAvailable(pincode: event.pincode));
        } else {
          final zoneInfo = deliveryInfo.zoneInfo;

          // Determine actual delivery charges based on express delivery
          double actualDeliveryCharges = zoneInfo.deliveryCharges;
          String actualEta = zoneInfo.etaDisplay;

          if (event.isExpress && zoneInfo.expressDelivery.available) {
            actualDeliveryCharges = zoneInfo.expressDelivery.charges;
            actualEta = zoneInfo.expressDelivery.etaDisplay;
          }

          // If free delivery is applicable, set delivery charges to 0
          if (zoneInfo.isFreeDelivery) {
            actualDeliveryCharges = 0.0;
          }

          emit(
            DeliveryLoaded(
              pincode: event.pincode,
              deliveryInfo: deliveryInfo,
              isExpressDelivery: event.isExpress,
              isDeliveryAvailable: true,
              deliveryCharges: actualDeliveryCharges,
              codCharges: zoneInfo.codCharges,
              etaDisplay: actualEta,
              isFreeDelivery: zoneInfo.isFreeDelivery,
              freeDeliveryThreshold: zoneInfo.freeDeliveryThreshold,
              codAvailable: zoneInfo.codAvailable,
              minEta: zoneInfo.eta.min,
              maxEta: zoneInfo.eta.max,
            ),
          );
        }
      },
    );
  }
}
