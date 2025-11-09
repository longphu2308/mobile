class ShipperOrder {
  final String id;
  final String customerName;
  final String address;
  final double distanceKm;
  final String status;
  final double total;
  final List<String> items;
  final String eta;
  final String? restaurantName;
  final double? fee;

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
  });

  static List<ShipperOrder> mockOrders() {
    return [
      ShipperOrder(
        id: 'SO-1001',
        customerName: 'Nguyễn Văn A',
        address: '123 Lê Lợi, Q1, TP. HCM',
        distanceKm: 2.4,
        status: 'Assigned',
        total: 120000,
        items: ['Bún bò', 'Trà đá'],
        eta: '15 mins',
        restaurantName: 'Quán Bún Bò 123',
        fee: 25000,
      ),
      ShipperOrder(
        id: 'SO-1002',
        customerName: 'Trần Thị B',
        address: '45 Nguyễn Huệ, Q1, TP. HCM',
        distanceKm: 4.6,
        status: 'Nearby',
        total: 89000,
        items: ['Phở', 'Nước cam'],
        eta: '22 mins',
        restaurantName: 'Phở 77',
        fee: 30000,
      ),
      ShipperOrder(
        id: 'SO-1003',
        customerName: 'Lê C',
        address: '12C Đường A, Q3, TP. HCM',
        distanceKm: 1.2,
        status: 'Pickup',
        total: 45000,
        items: ['Cơm tấm'],
        eta: '8 mins',
        restaurantName: 'Cơm Tấm Sài Gòn',
        fee: 15000,
      ),
    ];
  }

  String? get feeString => fee == null ? null : '${fee!.toInt()} VND';
}
