import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:one_atta/core/constants/app_assets.dart';

class MainNavigationPage extends StatelessWidget {
  final Widget child;

  const MainNavigationPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // keep selected index in sync with initialIndex provided by ShellRoute
    // (MainNavigationPage will be rebuilt with updated initialIndex when shell route changes)

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/orders');
          break;
        case 2:
          context.go('/reels');
          break;
        case 3:
          context.go('/recipes');
          break;
        case 4:
          context.go('/more');
          break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        selectedItemColor: Theme.of(context).colorScheme.primaryContainer,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        unselectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        selectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primaryContainer,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        selectedFontSize: 12.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        onTap: onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.homeIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 0
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.ordersIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 1
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.reelsIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 2
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.recipesIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 3
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.moreIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 4
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/reels')) return 2;
    if (location.startsWith('/recipes')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }
}
