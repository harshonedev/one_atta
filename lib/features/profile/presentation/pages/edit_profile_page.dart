import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/profile/domain/entities/profile_update_entity.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(const GetUserProfileRequested());
    final initialProfile = context.read<UserProfileBloc>().state;
    if (initialProfile is UserProfileLoaded) {
      _nameController = TextEditingController(
        text: initialProfile.profile.name,
      );
      _emailController = TextEditingController(
        text: initialProfile.profile.email,
      );
      _mobileController = TextEditingController(
        text: initialProfile.profile.mobile,
      );
      _profilePictureUrl = initialProfile.profile.profilePicture;
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _mobileController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = ProfileUpdateEntity(
        name: _nameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        profilePicture: _profilePictureUrl,
      );
      context.read<UserProfileBloc>().add(
        UpdateProfileRequested(profileUpdate: updatedProfile),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdated) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            Navigator.of(context).pop();
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    BlocBuilder<UserProfileBloc, UserProfileState>(
                      builder: (context, state) {
                        return TextButton(
                          onPressed: state is UserProfileLoading
                              ? null
                              : _submitForm,
                          child: Text(
                            'Save',
                            style: textTheme.titleMedium?.copyWith(
                              color: state is UserProfileLoading
                                  ? colorScheme.onSurface.withValues(alpha: 0.5)
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Profile Picture Section
              BlocBuilder<UserProfileBloc, UserProfileState>(
                builder: (context, state) {
                  if (state is UserProfileLoaded) {
                    final profile = state.profile;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  profile.profilePicture != null &&
                                      profile.profilePicture!.isNotEmpty
                                  ? NetworkImage(profile.profilePicture!)
                                  : null,
                              child:
                                  profile.profilePicture == null ||
                                      profile.profilePicture!.isEmpty
                                  ? Text(
                                      profile.name.isNotEmpty
                                          ? profile.name[0].toUpperCase()
                                          : 'U',
                                      style: textTheme.displaySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.name,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 12,
                          //     vertical: 6,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: colorScheme.surfaceContainerHighest,
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Icon(
                          //         Icons.camera_alt_outlined,
                          //         size: 16,
                          //         color: colorScheme.onSurfaceVariant,
                          //       ),
                          //       const SizedBox(width: 6),
                          //       Text(
                          //         'Tap to change profile photo',
                          //         style: textTheme.bodySmall?.copyWith(
                          //           color: colorScheme.onSurfaceVariant,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox(height: 200);
                },
              ),

              // Form Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          'Full Name',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Enter your full name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Email
                        Text(
                          'Email',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Phone Number
                        Text(
                          'Phone Number',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _mobileController,
                          hintText: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid mobile number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Bottom Buttons
                        Column(
                          children: [
                            // Save Changes Button
                            BlocBuilder<UserProfileBloc, UserProfileState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: state is UserProfileLoading
                                        ? null
                                        : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: state is UserProfileLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    colorScheme.onPrimary,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            'Save Changes',
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onPrimary,
                                                ),
                                          ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Cancel Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.onSurfaceVariant,
                                  side: BorderSide(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24), // Bottom padding
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
