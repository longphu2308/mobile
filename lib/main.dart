import 'package:flutter/material.dart';
import 'Owner/Dashboard/dashboard_screen.dart';
import 'Owner/Dashboard/orders_screen.dart';
import 'Owner/Dashboard/menu_screen.dart';
import 'Owner/Dashboard/edit_food_screen.dart';
import 'Owner/Dashboard/promotions_screen.dart';
import 'Owner/Dashboard/profile_screen.dart';
import 'Owner/Dashboard/report_screen.dart';
import 'Owner/Dashboard/support_screen.dart';

void main() {
  runApp(const FoodStoreApp());
}

class FoodStoreApp extends StatelessWidget {
  const FoodStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Store Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const StaffMainScreen(),
    );
  }
}

/// Màn hình chính của chủ quán (Bottom Navigation)
class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
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
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepOrange),
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
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
