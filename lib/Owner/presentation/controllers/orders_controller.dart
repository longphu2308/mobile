import 'package:flutter/material.dart';

class OrdersController extends ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'name': 'Cơm gà chiên giòn',
      'price': 45000,
      'status': 'Chờ xác nhận',
      'note': 'Không cay, thêm tương ớt',
    },
    {
      'id': 'ORD002',
      'name': 'Bún bò Huế',
      'price': 50000,
      'status': 'Đang chuẩn bị',
      'note': 'Ít hành lá',
    },
    {
      'id': 'ORD003',
      'name': 'Trà đào cam sả',
      'price': 30000,
      'status': 'Đang giao',
      'note': 'Giao cho tài xế A123',
    },
    {
      'id': 'ORD004',
      'name': 'Cơm chiên hải sản',
      'price': 55000,
      'status': 'Hoàn tất',
      'note': 'Khách thanh toán tiền mặt',
    },
    {
      'id': 'ORD005',
      'name': 'Mì xào bò',
      'price': 42000,
      'status': 'Đã hủy',
      'note': 'Khách hủy đơn',
    },
  ];

  List<Map<String, dynamic>> get orders => _orders;

  Color statusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đang chuẩn bị':
        return Colors.blue;
      case 'Đang giao':
        return Colors.purple;
      case 'Hoàn tất':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void updateStatus(int index) {
    final current = _orders[index]['status'];
    switch (current) {
      case 'Chờ xác nhận':
        _orders[index]['status'] = 'Đang chuẩn bị';
        break;
      case 'Đang chuẩn bị':
        _orders[index]['status'] = 'Đang giao';
        break;
      case 'Đang giao':
        _orders[index]['status'] = 'Hoàn tất';
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void cancelOrder(int index) {
    _orders[index]['status'] = 'Đã hủy';
    notifyListeners();
  }
}
