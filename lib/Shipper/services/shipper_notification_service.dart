import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/Shipper/controllers/shipper_controller.dart';

class ShipperNotificationService {
  static final ShipperNotificationService _instance =
      ShipperNotificationService._internal();
  factory ShipperNotificationService() => _instance;
  ShipperNotificationService._internal();

  bool _isDialogShowing = false;

  /// Show notification when new order is available
  void showNewOrderNotification(OrderModel order) {
    if (_isDialogShowing) return; // Prevent multiple dialogs

    _isDialogShowing = true;

    // Format total amount
    final formattedAmount = order.totalAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button dismissal
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.orange),
              const SizedBox(width: 8),
              const Expanded(child: Text('Đơn hàng mới!')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mã đơn: ${order.id.substring(0, 8)}...',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${order.items.length} món',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedAmount VND',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _isDialogShowing = false;
                // Decline order
                try {
                  final shipperController = Get.find<ShipperController>();
                  shipperController.declineOrder(order.id);
                } catch (e) {
                  print('Error declining order: $e');
                }
              },
              child: const Text('Từ chối'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                _isDialogShowing = false;
                // Accept order
                try {
                  final shipperController = Get.find<ShipperController>();
                  final success = await shipperController.acceptOrder(order.id);
                  if (success) {
                    Get.snackbar(
                      'Thành công',
                      'Bạn đã nhận đơn hàng',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Không thể nhận đơn hàng. Có thể đã được nhận bởi shipper khác.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    'Lỗi',
                    'Không thể nhận đơn hàng: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Nhận đơn'),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent dismissing by tapping outside
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  /// Show notification when order is cancelled due to timeout
  void showOrderCancelledNotification(String orderId) {
    Get.snackbar(
      'Đơn hàng đã hủy',
      'Đơn hàng $orderId đã bị hủy do không có tài xế nhận trong 1 phút',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  /// Show notification when restaurant confirms order
  void showOrderConfirmedNotification(String orderId) {
    Get.snackbar(
      'Đơn hàng đã được xác nhận',
      'Quán ăn đã xác nhận đơn hàng $orderId',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show notification when order is ready for pickup
  void showOrderReadyNotification(String orderId) {
    Get.snackbar(
      'Đơn hàng sẵn sàng',
      'Đơn hàng $orderId đã sẵn sàng để lấy',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
