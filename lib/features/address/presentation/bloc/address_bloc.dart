import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/address/domain/repositories/address_repository.dart';
import 'package:one_atta/features/address/presentation/bloc/address_event.dart';
import 'package:one_atta/features/address/presentation/bloc/address_state.dart';
import 'package:one_atta/features/auth/domain/repositories/auth_repository.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository repository;
  final Logger logger = Logger();
  final AuthRepository authRepository;

  AddressBloc({required this.repository, required this.authRepository})
    : super(const AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<RefreshAddresses>(_onRefreshAddresses);
    on<LoadAddressById>(_onLoadAddressById);
    on<CreateAddress>(_onCreateAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    String? tokenS;
    final tokenResult = await authRepository.getToken();
    logger.i("token result - $tokenResult");
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );
    logger.i("User token - $tokenS");
    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }
    final result = await repository.getAllAddresses(token: tokenS!);

    result.fold(
      (failure) {
        logger.e('Failed to load addresses: ${failure.message}');
        emit(AddressError(failure.message, failure: failure));
      },
      (addresses) {
        logger.i('Loaded ${addresses.length} addresses');
        emit(AddressesLoaded(addresses));
      },
    );
  }

  Future<void> _onRefreshAddresses(
    RefreshAddresses event,
    Emitter<AddressState> emit,
  ) async {
    // Keep the current state if already loaded, just refetch
    String? tokenS;
    final tokenResult = await authRepository.getToken();
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );

    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }
    final result = await repository.getAllAddresses(token: tokenS!);

    result.fold(
      (failure) {
        logger.e('Failed to refresh addresses: ${failure.message}');
        emit(AddressError(failure.message, failure: failure));
      },
      (addresses) {
        logger.i('Refreshed ${addresses.length} addresses');
        emit(AddressesLoaded(addresses));
      },
    );
  }

  Future<void> _onLoadAddressById(
    LoadAddressById event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());
    String? tokenS;
    final tokenResult = await authRepository.getToken();
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );

    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }
    final result = await repository.getAddressById(
      event.addressId,
      token: tokenS!,
    );

    result.fold(
      (failure) {
        logger.e('Failed to load address: ${failure.message}');
        emit(AddressError(failure.message, failure: failure));
      },
      (address) {
        logger.i('Loaded address: ${address.id}');
        emit(AddressLoaded(address));
      },
    );
  }

  Future<void> _onCreateAddress(
    CreateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressCreating());
    String? tokenS;
    final tokenResult = await authRepository.getToken();
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );

    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }
    // logs alll the event parameters
    logger.i(
      'Creating address with label: ${event.label}, '
      'addressLine1: ${event.addressLine1}, '
      'addressLine2: ${event.addressLine2}, '
      'landmark: ${event.landmark}, '
      'city: ${event.city}, '
      'state: ${event.state}, '
      'postalCode: ${event.postalCode}, '
      'country: ${event.country}, '
      'recipientName: ${event.recipientName}, '
      'primaryPhone: ${event.primaryPhone}, '
      'secondaryPhone: ${event.secondaryPhone}, '
      'geo: ${event.geo}, '
      'isDefault: ${event.isDefault}, '
      'instructions: ${event.instructions}',
    );

    final result = await repository.createAddress(
      token: tokenS!,
      label: event.label,
      addressLine1: event.addressLine1,
      addressLine2: event.addressLine2,
      landmark: event.landmark,
      city: event.city,
      state: event.state,
      postalCode: event.postalCode,
      country: event.country,
      recipientName: event.recipientName,
      primaryPhone: event.primaryPhone,
      secondaryPhone: event.secondaryPhone,
      geo: event.geo,
      isDefault: event.isDefault,
      instructions: event.instructions,
    );

    result.fold(
      (failure) {
        logger.e('Failed to create address: ${failure.message}');
        // Parse validation errors for better user feedback
        String errorMessage = failure.message;
        if (errorMessage.contains('geo.coordinates') &&
            errorMessage.contains('address_line1')) {
          errorMessage =
              'Please ensure you have selected a location on the map and filled in the address line 1 field.';
        } else if (errorMessage.contains('geo.coordinates')) {
          errorMessage = 'Please select a location on the map.';
        } else if (errorMessage.contains('address_line1')) {
          errorMessage = 'Please fill in the address line 1 field.';
        }
        emit(AddressError(errorMessage, failure: failure));
      },
      (address) {
        logger.i('Created address: ${address.id}');
        emit(AddressCreated(address));
        // Automatically refresh addresses list
        add(const LoadAddresses());
      },
    );
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressUpdating());

    String? tokenS;
    final tokenResult = await authRepository.getToken();
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );

    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }

    final result = await repository.updateAddress(
      token: tokenS!,
      addressId: event.addressId,
      label: event.label,
      addressLine1: event.addressLine1,
      addressLine2: event.addressLine2,
      landmark: event.landmark,
      city: event.city,
      state: event.state,
      postalCode: event.postalCode,
      country: event.country,
      recipientName: event.recipientName,
      primaryPhone: event.primaryPhone,
      secondaryPhone: event.secondaryPhone,
      geo: event.geo,
      isDefault: event.isDefault,
      instructions: event.instructions,
    );

    result.fold(
      (failure) {
        logger.e('Failed to update address: ${failure.message}');
        emit(AddressError(failure.message, failure: failure));
      },
      (address) {
        logger.i('Updated address: ${address.id}');
        emit(AddressUpdated(address));
        // Automatically refresh addresses list
        add(const LoadAddresses());
      },
    );
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressDeleting());
    String? tokenS;
    final tokenResult = await authRepository.getToken();
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );

    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }

    final result = await repository.deleteAddress(
      event.addressId,
      token: tokenS!,
    );

    result.fold(
      (failure) {
        logger.e('Failed to delete address: ${failure.message}');
        emit(AddressError(failure.message, failure: failure));
      },
      (address) {
        logger.i('Deleted address: ${address.id}');
        emit(AddressDeleted(address));
        // Automatically refresh addresses list
        add(const LoadAddresses());
      },
    );
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(const DefaultAddressSetting());
    String? tokenS;
    final tokenResult = await authRepository.getToken();
    tokenResult.fold(
      (failure) => emit(AddressError(failure.message, failure: failure)),
      (token) => tokenS = token,
    );

    if (tokenS == null) {
      return emit(const AddressError("User not authenticated"));
    }

    final result = await repository.setDefaultAddress(
      event.addressId,
      token: tokenS!,
    );

    result.fold(
      (failure) {
        logger.e('Failed to set default address: ${failure.message}');
        emit(AddressError(failure.message, failure: failure));
      },
      (address) {
        logger.i('Set default address: ${address.id}');
        emit(DefaultAddressSet(address));
        // Automatically refresh addresses list
        add(const LoadAddresses());
      },
    );
  }
}
