import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/views/dashboard/dashboard/dashboard_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/orders/orders_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/menu/menu_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/promotions/promotions_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/profile/profile_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/report/report_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/menu/edit_food_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/support/support_screen.dart';
import 'package:mobile/User/utils/utils.dart';

/// Màn hình chính của chủ quán (Bottom Navigation)
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    OrdersScreen(),
    MenuScreen(),
    PromotionsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Promos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/chef.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Food Store Manager',
                    style: TextStyle(color: whiteColor, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _navigateToScreen(0),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders'),
              onTap: () => _navigateToScreen(1),
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Menu'),
              onTap: () => _navigateToScreen(2),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Food'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditFoodScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Promotions'),
              onTap: () => _navigateToScreen(3),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign out'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // đóng Drawer
  }
}
