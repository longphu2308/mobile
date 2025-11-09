import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';

class PickupConfirm extends StatelessWidget {
  static const routeName = '/shipper/pickup-confirm';
  const PickupConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as ShipperOrder;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pickup ${order.id}'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Take a photo of the package (mock)'),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  color: bgColor,
                  child: const Center(child: Icon(Icons.camera_alt, size: 48)),
                ),
                const SizedBox(height: 12),
                const FoodieTextField(label: 'OTP', hint: 'Enter pickup code'),
                const SizedBox(height: 20),
                FoodieButton(
                  text: 'Confirm pickup',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pickup confirmed (mock)')),
                    );
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/shipper/dashboard'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
