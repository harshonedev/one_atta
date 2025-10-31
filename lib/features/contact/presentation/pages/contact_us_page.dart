import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:one_atta/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:one_atta/features/contact/presentation/bloc/contact_event.dart';
import 'package:one_atta/features/contact/presentation/bloc/contact_state.dart';
import 'package:one_atta/features/contact/domain/entities/contact_entity.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(const LoadContactDetails());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
          if (state is ContactLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ContactError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<ContactBloc>().add(
                        const LoadContactDetails(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ContactLoaded) {
            return _buildContactContent(context, state.contact);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContactContent(BuildContext context, ContactEntity contact) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ContactBloc>().add(const LoadContactDetails());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Get in Touch',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re here to help and answer any question you might have',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Email Section
          if (contact.supportEmail != null ||
              contact.salesEmail != null ||
              contact.infoEmail != null)
            _buildSection(
              context,
              icon: Icons.email,
              title: 'Email',
              children: [
                if (contact.supportEmail != null &&
                    contact.supportEmail!.isNotEmpty)
                  _buildContactTile(
                    context,
                    icon: Icons.support_agent,
                    title: 'Support',
                    subtitle: contact.supportEmail!,
                    onTap: () => _launchEmail(contact.supportEmail!),
                  ),
                if (contact.salesEmail != null &&
                    contact.salesEmail!.isNotEmpty)
                  _buildContactTile(
                    context,
                    icon: Icons.business_center,
                    title: 'Sales',
                    subtitle: contact.salesEmail!,
                    onTap: () => _launchEmail(contact.salesEmail!),
                  ),
                if (contact.infoEmail != null && contact.infoEmail!.isNotEmpty)
                  _buildContactTile(
                    context,
                    icon: Icons.info,
                    title: 'General Info',
                    subtitle: contact.infoEmail!,
                    onTap: () => _launchEmail(contact.infoEmail!),
                  ),
              ],
            ),

          // Phone Section
          if (contact.supportPhone != null ||
              contact.salesPhone != null ||
              contact.whatsappNumber != null)
            _buildSection(
              context,
              icon: Icons.phone,
              title: 'Phone',
              children: [
                if (contact.supportPhone != null &&
                    contact.supportPhone!.isNotEmpty)
                  _buildContactTile(
                    context,
                    icon: Icons.support_agent,
                    title: 'Support',
                    subtitle: contact.supportPhone!,
                    onTap: () => _launchPhone(contact.supportPhone!),
                  ),
                if (contact.salesPhone != null &&
                    contact.salesPhone!.isNotEmpty)
                  _buildContactTile(
                    context,
                    icon: Icons.business_center,
                    title: 'Sales',
                    subtitle: contact.salesPhone!,
                    onTap: () => _launchPhone(contact.salesPhone!),
                  ),
                if (contact.whatsappNumber != null &&
                    contact.whatsappNumber!.isNotEmpty)
                  _buildContactTile(
                    context,
                    icon: Icons.chat,
                    title: 'WhatsApp',
                    subtitle: contact.whatsappNumber!,
                    onTap: () => _launchWhatsApp(contact.whatsappNumber!),
                  ),
              ],
            ),

          // Office Address
          if (contact.officeAddress != null)
            _buildSection(
              context,
              icon: Icons.location_on,
              title: 'Office Address',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.officeAddress!.fullAddress,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (contact.mapLink != null &&
                          contact.mapLink!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _launchUrl(contact.mapLink!),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Open in Maps'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

          // Business Hours
          if (contact.businessHours != null)
            _buildSection(
              context,
              icon: Icons.access_time,
              title: 'Business Hours',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildBusinessHourRow(
                        context,
                        'Monday',
                        contact.businessHours!.monday,
                      ),
                      _buildBusinessHourRow(
                        context,
                        'Tuesday',
                        contact.businessHours!.tuesday,
                      ),
                      _buildBusinessHourRow(
                        context,
                        'Wednesday',
                        contact.businessHours!.wednesday,
                      ),
                      _buildBusinessHourRow(
                        context,
                        'Thursday',
                        contact.businessHours!.thursday,
                      ),
                      _buildBusinessHourRow(
                        context,
                        'Friday',
                        contact.businessHours!.friday,
                      ),
                      _buildBusinessHourRow(
                        context,
                        'Saturday',
                        contact.businessHours!.saturday,
                      ),
                      _buildBusinessHourRow(
                        context,
                        'Sunday',
                        contact.businessHours!.sunday,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

          // Website
          if (contact.website != null && contact.website!.isNotEmpty)
            _buildSection(
              context,
              icon: Icons.language,
              title: 'Website',
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Visit Our Website'),
                  subtitle: Text(contact.website!),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _launchUrl(contact.website!),
                ),
              ],
            ),

          // Social Media
          if (contact.socialMedia != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (contact.socialMedia!.facebook != null &&
                      contact.socialMedia!.facebook!.isNotEmpty)
                    _buildSocialButton(
                      context,
                      icon: Icons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () => _launchUrl(contact.socialMedia!.facebook!),
                    ),
                  if (contact.socialMedia!.instagram != null &&
                      contact.socialMedia!.instagram!.isNotEmpty)
                    _buildSocialButton(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Instagram',
                      color: const Color(0xFFE4405F),
                      onTap: () => _launchUrl(contact.socialMedia!.instagram!),
                    ),
                  if (contact.socialMedia!.twitter != null &&
                      contact.socialMedia!.twitter!.isNotEmpty)
                    _buildSocialButton(
                      context,
                      icon: Icons.flutter_dash,
                      label: 'Twitter',
                      color: const Color(0xFF1DA1F2),
                      onTap: () => _launchUrl(contact.socialMedia!.twitter!),
                    ),
                  if (contact.socialMedia!.linkedin != null &&
                      contact.socialMedia!.linkedin!.isNotEmpty)
                    _buildSocialButton(
                      context,
                      icon: Icons.business,
                      label: 'LinkedIn',
                      color: const Color(0xFF0A66C2),
                      onTap: () => _launchUrl(contact.socialMedia!.linkedin!),
                    ),
                  if (contact.socialMedia!.youtube != null &&
                      contact.socialMedia!.youtube!.isNotEmpty)
                    _buildSocialButton(
                      context,
                      icon: Icons.play_circle_filled,
                      label: 'YouTube',
                      color: const Color(0xFFFF0000),
                      onTap: () => _launchUrl(contact.socialMedia!.youtube!),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _buildBusinessHourRow(
    BuildContext context,
    String day,
    String? hours, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hours ?? 'Closed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hours != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
