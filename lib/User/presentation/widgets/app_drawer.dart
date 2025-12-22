import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/config/routes.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColorDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          userDashboardRoute,
                          arguments: {'initialIndex': 2},
                        );
                      },
                    ),
                    const Divider(
                      color: Colors.white30,
                      height: 1,
                      thickness: 1,
                    ),
                    _DrawerMenuItem(
                      icon: Icons.shopping_cart_outlined,
                      title: 'orders',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          userDashboardRoute,
                          arguments: {'initialIndex': 3},
                        );
                      },
                    ),
                    const Divider(
                      color: Colors.white30,
                      height: 1,
                      thickness: 1,
                    ),
                    _DrawerMenuItem(
                      icon: Icons.local_offer_outlined,
                      title: 'Voucher',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to voucher screen
                      },
                    ),
                    const Divider(
                      color: Colors.white30,
                      height: 1,
                      thickness: 1,
                    ),
                    _DrawerMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Privacy policy',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to privacy policy screen
                      },
                    ),
                    // No separator before Security
                    _DrawerMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Security',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, userChangePasswordRoute);
                      },
                    ),
                  ],
                ),
              ),
              // Sign-out Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: GetBuilder<AuthController>(
                  builder: (authController) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _showSignOutDialog(context, authController);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sign-out',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: whiteColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: whiteColor, size: 24),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
