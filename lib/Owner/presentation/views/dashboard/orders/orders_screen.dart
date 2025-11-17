import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/orders_controller.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late OrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrdersController();
    _controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<OrdersController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              title: const Text(
                'Quản lý đơn hàng',
                style: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: BackButton(color: blackColor),
            ),
            body: ListView.separated(
              padding: const EdgeInsets.all(horizontalPadding),
              itemCount: controller.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return OrderCard(
                  order: order,
                  statusColor: controller.statusColor(order.status),
                  onUpdateStatus: () => controller.updateStatus(
                    order.id,
                    _getNextStatus(order.status),
                  ),
                  onCancel: () => controller.cancelOrder(order.id),
                  onShowDetail: () => _showOrderDetail(context, order),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'preparing';
      case 'preparing':
        return 'delivering';
      case 'delivering':
        return 'delivered';
      default:
        return currentStatus;
    }
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đơn hàng #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Khách hàng: ${order.userId}'),
              Text('Địa chỉ: ${order.deliveryAddress}'),
              Text('Tổng tiền: ₫${order.totalAmount}'),
              const SizedBox(height: 10),
              const Text(
                'Món ăn:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...order.items.map(
                (item) =>
                    Text('${item.foodName} x${item.quantity} - ₫${item.price}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
