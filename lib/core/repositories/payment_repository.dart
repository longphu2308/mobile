import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/models/payment_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'payments';

  // Lấy payment theo order ID
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PaymentModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting payment by order: $e');
      return null;
    }
  }

  // Lấy tất cả payments của user
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user payments: $e');
      return [];
    }
  }

  // Lấy payment theo ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(paymentId).get();
      if (doc.exists) {
        return PaymentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting payment: $e');
      return null;
    }
  }

  // Tạo payment mới
  Future<String?> createPayment(PaymentModel payment) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(payment.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  // Cập nhật payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  // Cập nhật payment với transaction ID
  Future<bool> updatePaymentTransaction(
    String paymentId,
    String transactionId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(paymentId).update({
        'transactionId': transactionId,
      });
      return true;
    } catch (e) {
      print('Error updating payment transaction: $e');
      return false;
    }
  }

  // Stream để lắng nghe payments của user
  Stream<List<PaymentModel>> userPaymentsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
