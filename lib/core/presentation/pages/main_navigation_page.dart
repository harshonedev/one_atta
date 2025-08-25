import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_atta/core/constants/app_assets.dart';
import 'package:one_atta/features/home/presentation/pages/home_page.dart';
import 'package:one_atta/features/orders/presentation/pages/orders_page.dart';
import 'package:one_atta/features/reels/presentation/pages/reels_page.dart';
import 'package:one_atta/features/recipes/presentation/pages/recipes_page.dart';
import 'package:one_atta/features/more/presentation/pages/more_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OrdersPage(),
    const ReelsPage(),
    const RecipesPage(),
    const MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
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
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.homeIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0
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
                _selectedIndex == 1
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
                _selectedIndex == 2
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.recipesIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _selectedIndex == 3
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
                _selectedIndex == 4
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
}
