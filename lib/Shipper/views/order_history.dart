import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/User/utils/utils.dart';

class OrderHistory extends StatefulWidget {
  static const routeName = '/shipper/history';
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  late List<ShipperOrder> allOrders;
  late List<ShipperOrder> filtered;
  String query = '';

  @override
  void initState() {
    super.initState();
    allOrders = ShipperOrder.mockOrders();
    filtered = List.from(allOrders);
  }

  void _filter(String q) {
    setState(() {
      query = q;
      filtered = allOrders
          .where(
            (o) =>
                o.id.contains(q) ||
                o.customerName.toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      allOrders = ShipperOrder.mockOrders();
      _filter(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm theo mã hoặc tên',
              ),
              onChanged: _filter,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => Card(
                    child: ListTile(
                      title: Text(filtered[i].id),
                      subtitle: Text(
                        '${filtered[i].customerName} • ${filtered[i].total} VND',
                      ),
                      trailing: Text(filtered[i].status),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/shipper/order-detail',
                        arguments: filtered[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
