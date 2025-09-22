import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/presentation/pages/error_page.dart';
import 'package:one_atta/features/address/domain/entities/address_entity.dart';
import 'package:one_atta/features/address/presentation/bloc/address_bloc.dart';
import 'package:one_atta/features/address/presentation/bloc/address_event.dart';
import 'package:one_atta/features/address/presentation/bloc/address_state.dart';
import 'package:one_atta/features/address/presentation/widgets/address_card.dart';
import 'package:one_atta/features/address/presentation/widgets/empty_addresses_widget.dart';

class AddressesListPage extends StatefulWidget {
  const AddressesListPage({super.key});

  @override
  State<AddressesListPage> createState() => _AddressesListPageState();
}

class _AddressesListPageState extends State<AddressesListPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AddressBloc>(context).add(LoadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return const AddressesListView();
  }
}

class AddressesListView extends StatelessWidget {
  const AddressesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Delivery Addresses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AddressDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Address deleted successfully'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return _buildLoadingState(context);
          }

          if (state is AddressError) {
            return ErrorPage(
              onRetry: () =>
                  context.read<AddressBloc>().add(const LoadAddresses()),
            );
          }

          if (state is AddressesLoaded) {
            if (state.addresses.isEmpty) {
              return const EmptyAddressesWidget();
            }
            return _buildAddressesList(context, state.addresses);
          }

          return _buildLoadingState(context);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.push('/address/add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildAddressesList(
    BuildContext context,
    List<AddressEntity> addresses,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AddressBloc>().add(const RefreshAddresses());
      },
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AddressCard(
              address: address,
              onEdit: () => context.push('/address/edit/${address.id}'),
              onDelete: () => _showDeleteConfirmation(context, address),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AddressEntity address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Address',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
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
              context.read<AddressBloc>().add(DeleteAddress(address.id));
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
