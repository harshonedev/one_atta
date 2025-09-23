import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/core/di/injection_container.dart';
import 'package:one_atta/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:one_atta/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:one_atta/features/profile/presentation/widgets/loyalty_history_list.dart';
import 'package:one_atta/features/profile/presentation/widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserProfileBloc>(
          create: (_) =>
              sl<UserProfileBloc>()..add(const GetUserProfileRequested()),
        ),
        BlocProvider<LoyaltyHistoryBloc>(
          create: (_) =>
              sl<LoyaltyHistoryBloc>()..add(const GetLoyaltyHistoryRequested()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<UserProfileBloc>().add(
              const GetUserProfileRequested(forceRefresh: true),
            );
            context.read<LoyaltyHistoryBloc>().add(
              const RefreshLoyaltyHistoryRequested(),
            );
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                UserProfileHeader(),
                SizedBox(height: 16),
                LoyaltyHistoryList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
