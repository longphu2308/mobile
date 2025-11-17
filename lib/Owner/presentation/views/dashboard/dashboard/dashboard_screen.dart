import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/dashboard_controller.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DashboardController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: orangeLight,
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 TRẠNG THÁI CỬA HÀNG
                  Center(
                    child: Column(
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: controller.isOpen
                                ? Colors.green[700]
                                : Colors.red[700],
                            letterSpacing: 1.2,
                          ),
                          child: Text(
                            controller.isOpen
                                ? "CỬA HÀNG ĐANG MỞ"
                                : "CỬA HÀNG ĐÃ ĐÓNG",
                          ),
                        ),
                        const SizedBox(height: 10),
                        Switch(
                          value: controller.isOpen,
                          onChanged: (_) => controller.toggleOpen(),
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔹 THÔNG TIN NHANH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoCard(
                        title: "Đơn hôm nay",
                        value: "25",
                        icon: Icons.receipt_long,
                        color: Colors.blue,
                      ),
                      InfoCard(
                        title: "Doanh thu",
                        value: "₫15,200",
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      InfoCard(
                        title: "Lượt xem",
                        value: "1,280",
                        icon: Icons.visibility,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 🔹 DOANH THU TUẦN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Tổng quan doanh thu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: 0.7,
                          color: orangeLight,
                          backgroundColor: Colors.orange,
                        ),
                        SizedBox(height: 8),
                        Text("Đã đạt 70% mục tiêu trong tuần này"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔹 ĐƠN HÀNG GẦN ĐÂY
                  const Text(
                    "Đơn hàng gần đây",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  OrderTile(
                    name: "Bánh mì thịt",
                    price: "₫25,000",
                    status: "Hoàn thành",
                  ),
                  OrderTile(
                    name: "Trà sữa trân châu",
                    price: "₫45,000",
                    status: "Đang giao",
                  ),
                  OrderTile(name: "Cơm gà", price: "₫50,000", status: "Đã hủy"),
                  OrderTile(
                    name: "Phở bò đặc biệt",
                    price: "₫65,000",
                    status: "Hoàn thành",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
