import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard/farmer_dashboard_screen.dart';
import 'products/farmer_products_screen.dart';
import 'deals/farmer_deals_screen.dart';
import '../customer/chat/chat_list_screen.dart';
import 'profile/farmer_profile_screen.dart';

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FarmerDashboardScreen(),
    FarmerProductsScreen(),
    FarmerDealsScreen(),
    ChatListScreen(),
    FarmerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined),
              activeIcon: Icon(Icons.handshake),
              label: 'Deals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture_outlined),
              activeIcon: Icon(Icons.agriculture),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
