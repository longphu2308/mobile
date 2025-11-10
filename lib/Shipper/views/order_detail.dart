import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/User/utils/utils.dart';

double _statusProgress(String status) {
  switch (status.toLowerCase()) {
    case 'assigned':
      return 0.0;
    case 'pickup':
      return 0.33;
    case 'nearby':
      return 0.15;
    case 'delivery':
    case 'delivering':
      return 0.66;
    case 'completed':
    case 'done':
      return 1.0;
    default:
      return 0.0;
  }
}

class OrderDetail extends StatelessWidget {
  static const routeName = '/shipper/order-detail';
  const OrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as ShipperOrder;
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.id}'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nhà hàng: ${order.restaurantName ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order.restaurantPhone ??
                                                '-'.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Mở dẫn đường (mock)'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.map),
                                    label: const Text('Đường đi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Customer info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khách hàng: ${order.customerName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Địa chỉ: ${order.address}'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order.customerPhone ?? '-',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Mở dẫn đường đến khách (mock)',
                                            ),
                                          ),
                                        ),
                                    icon: const Icon(Icons.navigation),
                                    label: const Text('Đường đi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Notes
                      if (order.items.isEmpty) const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text('Ghi chú: ${order.status}'),
                      ),

                      const SizedBox(height: 8),

                      // Items
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chi tiết đơn',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...order.items.map(
                                (i) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${i.name} x${i.qty}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${i.total.toInt()} VND',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tổng: ${order.total.toInt()} VND',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Status progress
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trạng thái đơn',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _statusProgress(order.status),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Pickup'),
                                  Text('Đang giao'),
                                  Text('Đã giao'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Map placeholder
                      Container(
                        height: 160,
                        color: bgColor,
                        child: const Center(child: Icon(Icons.map, size: 48)),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Action buttons fixed to bottom area with safe spacing
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/shipper/pickup-confirm',
                          arguments: order,
                        ),
                        child: const Text('Picked up'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/shipper/delivery-confirm',
                          arguments: order,
                        ),
                        child: const Text('Deliver'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
