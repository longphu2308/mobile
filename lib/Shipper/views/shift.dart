import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class ShiftPage extends StatefulWidget {
  static const routeName = '/shipper/shift';
  const ShiftPage({super.key});

  @override
  State<ShiftPage> createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  bool online = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift & Availability'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Online'),
              trailing: Switch(
                value: online,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => online = v),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Start Shift'),
            ),
          ],
        ),
      ),
    );
  }
}
