import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                      color: isOpen ? Colors.green[700] : Colors.red[700],
                      letterSpacing: 1.2,
                    ),
                    child: Text(isOpen ? "CỬA HÀNG ĐANG MỞ" : "CỬA HÀNG ĐÃ ĐÓNG"),
                  ),
                  const SizedBox(height: 10),
                  Switch(
                    value: isOpen,
                    onChanged: (value) {
                      setState(() => isOpen = value);
                    },
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
                _buildInfoCard("Đơn hôm nay", "25", Icons.receipt_long, Colors.blue),
                _buildInfoCard("Doanh thu", "₫15,200", Icons.attach_money, Colors.green),
                _buildInfoCard("Lượt xem", "1,280", Icons.visibility, Colors.purple),
              ],
            ),

            const SizedBox(height: 25),

            // 🔹 DOANH THU TUẦN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.7,
                    color: Colors.orangeAccent,
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
            _buildOrderTile("Bánh mì thịt", "₫25,000", "Hoàn thành"),
            _buildOrderTile("Trà sữa trân châu", "₫45,000", "Đang giao"),
            _buildOrderTile("Cơm gà", "₫50,000", "Đã hủy"),
            _buildOrderTile("Phở bò đặc biệt", "₫65,000", "Hoàn thành"),
          ],
        ),
      ),
    );
  }

  // 🔸 Widget thông tin nhanh
  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Widget hiển thị đơn hàng
  Widget _buildOrderTile(String name, String price, String status) {
    Color statusColor;
    if (status == "Hoàn thành") {
      statusColor = Colors.green;
    } else if (status == "Đang giao") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
          child: const Icon(Icons.fastfood, color: Colors.orange),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(price),
        trailing: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
