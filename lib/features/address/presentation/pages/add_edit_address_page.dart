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
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _onLocationChanged(LatLng position) {
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

      if (placemarks.isNotEmpty) {
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
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 15),
        );
      }
    });
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
    print(
      '🐛 DEBUG: Submitting address with geo: ${geo.coordinates}, addressLine1: ${_addressLine1Controller.text.trim()}',
    );

    if (widget.addressId == null) {
      // Create new address
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
          isDefault: _isDefault,
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
        ),
      );
    } else {
      // Update existing address
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
          isDefault: _isDefault,
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
          if (state is AddressLoaded && widget.addressId != null) {
            _populateFormWithAddress(state.address);
          }

          if (state is AddressCreated || state is AddressUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.addressId == null
                      ? 'Address added successfully'
                      : 'Address updated successfully',
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
                                  onSelected: (_) =>
                                      setState(() => _selectedLabel = label),
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
                          subtitle: Text(
                            'This address will be selected by default',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: _isDefault,
                          onChanged: (value) =>
                              setState(() => _isDefault = value),
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
                    state is AddressLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
