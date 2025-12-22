import 'package:mobile/core/models/payment_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class PaymentRepository {
  final _supabase = SupabaseService().client;
  final String _table = 'payments';

  // Lấy payment theo order ID
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('order_id', orderId)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return PaymentModel.fromMap(data, data['payment_id']);
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
      final data = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => PaymentModel.fromMap(item, item['payment_id']))
          .toList();
    } catch (e) {
      print('Error getting user payments: $e');
      return [];
    }
  }

  // Lấy payment theo ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('payment_id', paymentId)
          .maybeSingle();
      if (data != null) {
        return PaymentModel.fromMap(data, data['payment_id']);
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
      final data = await _supabase
          .from(_table)
          .insert(payment.toMap())
          .select()
          .single();
      return data['payment_id'];
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  // Cập nhật payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _supabase
          .from(_table)
          .update({'status': status})
          .eq('payment_id', paymentId);
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  // Cập nhật payment
  Future<bool> updatePayment(
    String paymentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _supabase
          .from(_table)
          .update(data)
          .eq('payment_id', paymentId);
      return true;
    } catch (e) {
      print('Error updating payment: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi của payment
  Stream<PaymentModel?> paymentStream(String paymentId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['payment_id'])
        .eq('payment_id', paymentId)
        .map((data) {
          if (data.isNotEmpty) {
            return PaymentModel.fromMap(data.first, data.first['payment_id']);
          }
          return null;
        });
  }
}
