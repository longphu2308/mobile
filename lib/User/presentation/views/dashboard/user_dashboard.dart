import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/views/dashboard/home/home_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/order_history/order_history_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/favorites/favorites_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/profile/profile_screen.dart';
import 'package:mobile/User/utils/utils.dart';

class UserDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const UserDashboardScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const UserProfileScreen();
      case 3:
        return const OrderHistoryScreen();
      default:
        return const HomeScreen();
    }
  }
}


