class OrderItem {
  final String name;
  final int qty;
  final double price;

  OrderItem({required this.name, required this.qty, required this.price});

  double get total => qty * price;

  String get priceString => '${price.toInt()} VND';
}

class ShipperOrder {
  final String id;
  final String customerName;
  final String address;
  final double distanceKm;
  final String status;
  final double total;
  final List<OrderItem> items;
  final String eta;
  final String? restaurantName;
  final double? fee;
  final String? customerPhone;
  final String? restaurantPhone;

  ShipperOrder({
    required this.id,
    required this.customerName,
    required this.address,
    required this.distanceKm,
    required this.status,
    required this.total,
    required this.items,
    required this.eta,
    this.restaurantName,
    this.fee,
    this.customerPhone,
    this.restaurantPhone,
  });

  static List<ShipperOrder> mockOrders() {
    return [
      ShipperOrder(
        id: 'SO-1001',
        customerName: 'Nguyễn Văn A',
        address: '123 Lê Lợi, Q1, TP. HCM',
        distanceKm: 2.4,
        status: 'Assigned',
        total: 84000,
        items: [
          OrderItem(name: 'Bún bò', qty: 1, price: 80000),
          OrderItem(name: 'Trà đá', qty: 1, price: 4000),
        ],
        eta: '15 mins',
        restaurantName: 'Quán Bún Bò 123',
        fee: 25000,
        customerPhone: '090-123-4567',
        restaurantPhone: '028-3912-3456',
      ),
      ShipperOrder(
        id: 'SO-1002',
        customerName: 'Trần Thị B',
        address: '45 Nguyễn Huệ, Q1, TP. HCM',
        distanceKm: 4.6,
        status: 'Nearby',
        total: 75000,
        items: [
          OrderItem(name: 'Phở', qty: 1, price: 60000),
          OrderItem(name: 'Nước cam', qty: 1, price: 15000),
        ],
        eta: '22 mins',
        restaurantName: 'Phở 77',
        fee: 30000,
        customerPhone: '091-222-3344',
        restaurantPhone: '028-3999-7788',
      ),
      ShipperOrder(
        id: 'SO-1003',
        customerName: 'Lê C',
        address: '12C Đường A, Q3, TP. HCM',
        distanceKm: 1.2,
        status: 'Pickup',
        total: 45000,
        items: [OrderItem(name: 'Cơm tấm', qty: 1, price: 45000)],
        eta: '8 mins',
        restaurantName: 'Cơm Tấm Sài Gòn',
        fee: 15000,
        customerPhone: '092-555-9000',
        restaurantPhone: '028-3876-4433',
      ),
    ];
  }

  String? get feeString => fee == null ? null : '${fee!.toInt()} VND';
}
