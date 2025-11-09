import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class ShipperProfile extends StatelessWidget {
  static const routeName = '/shipper/profile';
  const ShipperProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44)),
            const SizedBox(height: 12),
            const Text(
              'Người giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Vehicle: Motorbike • Plate: 79A-000.00'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // simple edit dialog (mock)
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Chỉnh sửa thông tin'),
                    content: const Text('Mock edit form goes here.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Chỉnh sửa'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // logout mock
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  authRoute,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Đăng xuất'),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Documents'),
              trailing: IconButton(
                icon: const Icon(Icons.upload_file),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
