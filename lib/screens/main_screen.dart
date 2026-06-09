import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'app_colors.dart';
import 'home_screen.dart';
import 'my_rides_screen.dart';
import 'profile.dart';
import 'wallet_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [HomeScreen(), MyRidesScreen(showBottomNav: false), WalletScreen(showBottomNav: false), ProfileScreen()];
    try {
      final provider = context.watch<AppProvider>();
      return Scaffold(
        body: IndexedStack(index: provider.currentIndex.clamp(0, 3), children: pages),
        bottomNavigationBar: _MainBottomNav(provider: provider),
      );
    } catch (_) {
      return ChangeNotifierProvider(create: (_) => AppProvider(), child: const MainScreen());
    }
  }
}

class _MainBottomNav extends StatelessWidget {
  final AppProvider provider;
  const _MainBottomNav({required this.provider});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7FF)),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: provider.currentIndex.clamp(0, 3),
            onTap: provider.setIndex,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.secondary,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.directions_car_filled_outlined), label: 'My Rides'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
            ],
          ),
        ),
      );
}