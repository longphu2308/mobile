import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class LiveTracking extends StatelessWidget {
  static const routeName = '/shipper/tracking';
  const LiveTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 96, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Map placeholder (mock)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
