import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
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

class OrderDetail extends StatefulWidget {
  static const routeName = '/shipper/order-detail';
  const OrderDetail({super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late ShipperOrder order;
  List<OrderItem> items = [];
  bool isLoadingItems = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! ShipperOrder) {
      // Defensive: if called without a proper ShipperOrder, go back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order data missing')));
        Navigator.maybePop(context);
      });
      return;
    }
    order = args as ShipperOrder;
    items = List.from(order.items);
    if (items.isEmpty) {
      _fetchItems();
    }
  }

  Future<void> _fetchItems() async {
    setState(() => isLoadingItems = true);
    try {
      final supabase = SupabaseService();
      // DEBUG: log before querying
      print('OrderDetail._fetchItems: fetching items for orderId=${order.id}');
      dynamic itemsData = await supabase.from('order_items').select().eq('order_id', order.id);
      print('OrderDetail._fetchItems: raw itemsData length=${(itemsData as List?)?.length ?? 0}');
      if ((itemsData as List?)?.isEmpty ?? true) {
        try {
          final orderWithItems = await supabase.from('orders').select('order_items(*)').eq('order_id', order.id).maybeSingle();
          final embedded = (orderWithItems != null && orderWithItems['order_items'] != null)
              ? (orderWithItems['order_items'] as List<dynamic>)
              : <dynamic>[];
          if (embedded.isNotEmpty) {
            itemsData = embedded;
            print('OrderDetail._fetchItems: fetched items via orders relation, count=${embedded.length}');
          }
        } catch (e) {
          // ignore
        }
      }
      final fetched = (itemsData as List? ?? []).map((i) {
        final price = (i['price'] as num?)?.toDouble() ?? 0.0;
        return OrderItem(
          name: i['food_name'] ?? '',
          qty: (i['quantity'] as int?) ?? (i['quantity'] as num?)?.toInt() ?? 0,
          price: price,
        );
      }).toList();
      setState(() {
        items = fetched;
      });
      print('ORDER.ID = ${order.id}');
      print('TYPE = ${order.id.runtimeType}');

    } catch (e) {
      // ignore errors for now
    } finally {
      setState(() => isLoadingItems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
          backgroundColor: whiteColor,
          foregroundColor: primaryColor,
          elevation: 0,
        ),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order!.id}'),
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
                              if ((order.restaurantAddress ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Text('Địa chỉ: ${order.restaurantAddress}'),
                                ),
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

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 12),

                      // Notes
                      if (items.isEmpty && !isLoadingItems) const SizedBox.shrink(),
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
                              if (isLoadingItems) const Center(child: CircularProgressIndicator()),
                              if (!isLoadingItems && items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Không có món hàng.'),
                                ),
                              // Items list
                              ...items.map((i) => Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.grey.shade200,
                                          child: Text('${i.qty}', style: const TextStyle(color: Colors.black)),
                                        ),
                                        title: Text(i.name, style: const TextStyle(fontSize: 14)),
                                        subtitle: Text('${i.price.toInt()} VND / cái'),
                                        trailing: Text('${i.total.toInt()} VND', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  )),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tổng', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${order.total.toInt()} VND', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
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
