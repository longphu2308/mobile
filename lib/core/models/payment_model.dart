import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String method; // 'cash', 'card', 'momo', 'zalopay', etc.
  final String status; // 'success', 'failed', 'pending'
  final String? transactionId; // từ gateway như Stripe, Momo
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });

  // Chuyển từ Firestore document sang model
  factory PaymentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PaymentModel(
      id: documentId,
      orderId: data['orderId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      method: data['method'] ?? 'cash',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    double? amount,
    String? method,
    String? status,
    String? transactionId,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
