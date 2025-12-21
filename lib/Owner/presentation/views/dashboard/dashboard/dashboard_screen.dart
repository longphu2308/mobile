import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/controllers/dashboard_controller.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/config/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(DashboardController());
    _controller.loadDashboardData();
  }

  Future<void> _confirmToggle(BuildContext context) async {
    final c = _controller;

    if (c.toggleCountToday >= 5) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Giới hạn thao tác"),
          content: const Text(
            "Bạn đã mở/đóng cửa hàng 5 lần hôm nay.\nVui lòng thử lại ngày mai.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.isOpen ? "Đóng cửa hàng?" : "Mở cửa hàng?"),
        content: Text("Bạn có chắc muốn ${c.isOpen ? "ĐÓNG" : "MỞ"} cửa hàng?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await c.toggleOpenConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = _controller;
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: orangeLight,
          title: const Text(
            "Dashboard",
            style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),

        body: c.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================
                    // STORE STATUS
                    // ==========================
                    Center(
                      child: Column(
                        children: [
                          Text(
                            c.isOpen ? "CỬA HÀNG ĐANG MỞ" : "CỬA HÀNG ĐÃ ĐÓNG",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: c.isOpen ? Colors.green : Colors.red,
                            ),
                          ),
                          Switch(
                            value: c.isOpen,
                            onChanged: (_) => _confirmToggle(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==========================
                    // ORDER + REVENUE STATS
                    // ==========================
                    Row(
                      children: [
                        Expanded(
                          child: InfoCard(
                            title: "Đơn hôm nay",
                            value: "${c.ordersToday}",
                            icon: Icons.today,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoCard(
                            title: "Đơn tuần",
                            value: "${c.ordersThisWeek}",
                            icon: Icons.view_week,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoCard(
                            title: "Đơn tháng",
                            value: "${c.ordersThisMonth}",
                            icon: Icons.calendar_month,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==========================
                    // RECENT ORDERS
                    // ==========================
                    const Text(
                      "Đơn hàng gần đây",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...c.recentOrders.map((order) {
                      return OrderTile(
                        name: order.items.first.foodName,
                        price: "₫${order.totalAmount.toStringAsFixed(0)}",
                        status: order.status,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ownerOrderDetailRoute,
                            arguments: {'order': order},
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
      );
    });
  }
}
