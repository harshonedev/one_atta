import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';
import 'package:one_atta/features/address/presentation/bloc/address_event.dart';
import 'package:one_atta/features/address/presentation/bloc/address_state.dart';

class AddEditAddressPage extends StatelessWidget {
  final String? addressId;

  const AddEditAddressPage({super.key, this.addressId});

  @override
  Widget build(BuildContext context) {
    return AddEditAddressView(addressId: addressId);
  }
}

class AddEditAddressView extends StatefulWidget {
  final String? addressId;

  const AddEditAddressView({super.key, this.addressId});

  @override
  State<AddEditAddressView> createState() => _AddEditAddressViewState();
}

class _AddEditAddressViewState extends State<AddEditAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(28.6139, 77.2090); // Default to Delhi
  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isLoadingLocation = false;
  Set<Marker> _markers = {};
  bool _hasOtherDefaultAddress = false;

  final List<String> _addressLabels = [
    'Home',
    'Work',
    'Apartment',
    'Office',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Load all addresses to check default status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressBloc>().add(const LoadAddresses());

      // Load address data if editing
      if (widget.addressId != null) {
        context.read<AddressBloc>().add(LoadAddressById(widget.addressId!));
      }
    });
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _markers = {
            Marker(
              markerId: const MarkerId('current_location'),
              position: _currentLocation,
              draggable: true,
              onDragEnd: (LatLng position) {
                _onLocationChanged(position);
              },
            ),
          };
          _isLoadingLocation = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 15),
        );

        _getAddressFromCoordinates(_currentLocation);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _onLocationChanged(LatLng position) {
    if (!mounted) return;
    setState(() {
      _currentLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: position,
          draggable: true,
          onDragEnd: _onLocationChanged,
        ),
      };
    });
    _getAddressFromCoordinates(position);
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _addressLine1Controller.text =
              '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim();
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _postalCodeController.text = place.postalCode ?? '';
          _landmarkController.text = place.subLocality ?? '';
        });
      }
    } catch (e) {
      // Handle geocoding error silently
    }
  }

  void _populateFormWithAddress(AddressEntity address) {
    _recipientNameController.text = address.recipientName;
    _phoneController.text = address.primaryPhone;
    _secondaryPhoneController.text = address.secondaryPhone ?? '';
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2 ?? '';
    _landmarkController.text = address.landmark ?? '';
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _instructionsController.text = address.instructions ?? '';

    if (!mounted) return;
    setState(() {
      _selectedLabel = address.label;
      _isDefault = address.isDefault;

      if (address.geo != null) {
        _currentLocation = LatLng(
          address.geo!.coordinates[1], // latitude
          address.geo!.coordinates[0], // longitude
        );
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation,
            draggable: true,
            onDragEnd: _onLocationChanged,
          ),
        };

        // Update map camera position after a short delay to ensure map controller is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_currentLocation, 15),
            );
          }
        });
      }
    });
  }

  void _updateExistingAddresses(List<AddressEntity> addresses) {
    if (!mounted) return;
    setState(() {
      // Check if any other address (not the current one being edited) is default
      _hasOtherDefaultAddress = addresses.any(
        (address) => address.isDefault && address.id != widget.addressId,
      );
    });
  }

  void _onDefaultToggleChanged(bool value) {
    if (value && _hasOtherDefaultAddress) {
      _showDefaultAddressWarning();
    } else {
      if (!mounted) return;
      setState(() => _isDefault = value);
    }
  }

  void _showDefaultAddressWarning() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Default Address',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Another address is already set as default. Setting this address as default will remove the default status from the other address. Do you want to continue?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (mounted) setState(() => _isDefault = true);
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validate that location is available
    if (_currentLocation.latitude == 0.0 && _currentLocation.longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final geo = GeoLocation(
      type: 'Point',
      coordinates: [_currentLocation.longitude, _currentLocation.latitude],
    );

    // Debug log to understand what data is being sent
    if (kDebugMode) {
      print(
        '🐛 DEBUG: Submitting address with geo: ${geo.coordinates}, addressLine1: ${_addressLine1Controller.text.trim()}',
      );
    }

    if (widget.addressId == null) {
      // Create new address (without setting as default initially)
      context.read<AddressBloc>().add(
        CreateAddress(
          label: _selectedLabel,
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim().isEmpty
              ? null
              : _addressLine2Controller.text.trim(),
          landmark: _landmarkController.text.trim().isEmpty
              ? null
              : _landmarkController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          recipientName: _recipientNameController.text.trim(),
          primaryPhone: _phoneController.text.trim(),
          secondaryPhone: _secondaryPhoneController.text.trim().isEmpty
              ? null
              : _secondaryPhoneController.text.trim(),
          geo: geo,
          isDefault: false, // Always set as false initially
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
        ),
      );
    } else {
      // Update existing address (without changing default status)
      context.read<AddressBloc>().add(
        UpdateAddress(
          addressId: widget.addressId!,
          label: _selectedLabel,
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim().isEmpty
              ? null
              : _addressLine2Controller.text.trim(),
          landmark: _landmarkController.text.trim().isEmpty
              ? null
              : _landmarkController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          recipientName: _recipientNameController.text.trim(),
          primaryPhone: _phoneController.text.trim(),
          secondaryPhone: _secondaryPhoneController.text.trim().isEmpty
              ? null
              : _secondaryPhoneController.text.trim(),
          geo: geo,
          isDefault: null, // Don't change default status in update
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.addressId == null ? 'Add Address' : 'Edit Address',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressesLoaded) {
            _updateExistingAddresses(state.addresses);
          }

          if (state is AddressLoaded && widget.addressId != null) {
            _populateFormWithAddress(state.address);
          }

          if (state is AddressCreated) {
            // If user wanted this address to be default, set it after creation
            if (_isDefault) {
              context.read<AddressBloc>().add(
                SetDefaultAddress(state.address.id),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Address added successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            }
          }

          if (state is AddressUpdated) {
            // Check if default status needs to be changed
            final currentAddress = state.address;
            final shouldBeDefault = _isDefault;
            final isCurrentlyDefault = currentAddress.isDefault;

            if (shouldBeDefault && !isCurrentlyDefault) {
              // User wants to set as default but it's not currently default
              context.read<AddressBloc>().add(
                SetDefaultAddress(currentAddress.id),
              );
            } else if (!shouldBeDefault && isCurrentlyDefault) {
              // This case should not happen in normal flow, but handle it
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Address updated successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            } else {
              // No default status change needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Address updated successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            }
          }

          if (state is DefaultAddressSet) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.addressId == null
                      ? 'Address added and set as default successfully'
                      : 'Address updated and set as default successfully',
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          }

          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Google Map
              Container(
                height: 250,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation,
                          zoom: 15,
                        ),
                        markers: _markers,
                        onTap: _onLocationChanged,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                      if (_isLoadingLocation)
                        Container(
                          color: Colors.white.withOpacity(0.8),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _getCurrentLocation,
                            icon: Icon(
                              Icons.my_location,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address Labels
                        Text(
                          'Save as',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _addressLabels.map((label) {
                              final isSelected = _selectedLabel == label;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  selected: isSelected,
                                  onSelected: (_) {
                                    if (mounted) {
                                      setState(() => _selectedLabel = label);
                                    }
                                  },
                                  label: Text(label),
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  checkmarkColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Contact Information
                        Text(
                          'Contact Information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _recipientNameController,
                          label: 'Recipient Name',

                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter recipient name'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',

                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Please enter phone number';
                            }
                            if (value!.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _secondaryPhoneController,
                          label: 'Alternate Phone (Optional)',

                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 24),

                        // Address Information
                        Text(
                          'Address Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _addressLine1Controller,
                          label: 'Address Line 1',

                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter address line 1'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _addressLine2Controller,
                          label: 'Address Line 2 (Optional)',
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _landmarkController,
                          label: 'Landmark (Optional)',
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'City',

                                validator: (value) => value?.isEmpty == true
                                    ? 'Please enter city'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'State',

                                validator: (value) => value?.isEmpty == true
                                    ? 'Please enter state'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _postalCodeController,
                          label: 'Postal Code',

                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Please enter postal code';
                            }
                            if (value!.length != 6) {
                              return 'Please enter a valid postal code';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _instructionsController,
                          label: 'Delivery Instructions (Optional)',

                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        // Default Address Toggle
                        SwitchListTile(
                          title: Text(
                            'Set as default address',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This address will be selected by default',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (_hasOtherDefaultAddress && !_isDefault)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Another address is currently set as default',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                          value: _isDefault,
                          onChanged: _onDefaultToggleChanged,
                          activeThumbColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: BlocBuilder<AddressBloc, AddressState>(
              builder: (context, state) {
                final isLoading =
                    state is AddressCreating ||
                    state is AddressUpdating ||
                    state is AddressLoading ||
                    state is DefaultAddressSetting;

                return ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.addressId == null
                              ? 'Add Address'
                              : 'Update Address',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.inverseSurface.withValues(alpha: 0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
