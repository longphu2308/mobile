import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/orders_controller.dart';
import 'package:mobile/Owner/presentation/views/dashboard/orders/order_detail_screen.dart';
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
                  onUpdateStatus: () =>
                      controller.updateStatus(order.id, order.status),
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

  void _showOrderDetail(BuildContext context, OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
    );
  }
}
