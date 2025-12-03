import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/User/utils/utils.dart';

class IncomingOrderModal extends StatefulWidget {
  final ShipperOrder order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int seconds;

  const IncomingOrderModal({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.seconds = 30,
  });

  @override
  State<IncomingOrderModal> createState() => _IncomingOrderModalState();
}

class _IncomingOrderModalState extends State<IncomingOrderModal> {
  late int remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remaining = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        remaining--;
        if (remaining <= 0) {
          _timer?.cancel();
          widget.onDecline();
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('New order'),
          Chip(label: Text('$remaining s')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Restaurant: ${o.restaurantName ?? "Unknown"}'),
          const SizedBox(height: 6),
          Text('Customer: ${o.customerName}'),
          const SizedBox(height: 6),
          Text('Distance: ${o.distanceKm} km'),
          const SizedBox(height: 6),
          Text('Fee: ${o.feeString ?? "-"}'),
          const SizedBox(height: 6),
          Text('ETA: ${o.eta}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            widget.onDecline();
            Navigator.pop(context);
          },
          child: const Text('Từ chối'),
        ),
        ElevatedButton(
          onPressed: () {
            _timer?.cancel();
            widget.onAccept();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text('Chấp nhận'),
        ),
      ],
    );
  }
}
