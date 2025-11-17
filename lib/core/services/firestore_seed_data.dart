import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script để seed data giả vào Firestore
/// Chạy script này bằng cách gọi từ main.dart hoặc tạo một screen riêng
/// LƯU Ý: Script này KHÔNG tạo users - users được tạo qua Firebase Auth

class FirestoreSeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Danh sách restaurantIds sẽ được tạo (giả sử có 3 quán)
  final List<Map<String, String>> _restaurantData = [
    {
      'ownerId': 'QvMogQswPQhMwersCfq6BcsI9GE2', // Thay bằng UID thật của owner từ Firebase Auth
      'name': 'Nhà hàng Hải Sản Biển Đông',
      'address': '123 Đường Võ Văn Kiệt, Quận 1, TP.HCM',
      'description':
          'Chuyên các món hải sản tươi sống, được chế biến theo phong cách Việt Nam hiện đại',
      'imageUrl': 'https://via.placeholder.com/300x200?text=Hai+San',
      'status': 'open',
    },
    {
      'ownerId': 'OWNER_ID_2',
      'name': 'Quán Cơm Tấm Sườn Bì Chả',
      'address': '456 Đường Lê Lợi, Quận 3, TP.HCM',
      'description':
          'Cơm tấm truyền thống, sườn nướng thơm ngon, giá cả phải chăng',
      'imageUrl': 'https://via.placeholder.com/300x200?text=Com+Tam',
      'status': 'open',
    },
    {
      'ownerId': 'OWNER_ID_3',
      'name': 'Trà Sữa & Café Phố',
      'address': '789 Đường Nguyễn Huệ, Quận 1, TP.HCM',
      'description':
          'Trà sữa và các loại thức uống hiện đại, không gian thoải mái',
      'imageUrl': 'https://via.placeholder.com/300x200?text=Tra+Sua',
      'status': 'open',
    },
  ];

  Future<void> seedAllData() async {
    print('🌱 Bắt đầu seed data vào Firestore...\n');

    try {
      // 1. Seed Restaurants
      print('📍 Đang tạo restaurants...');
      final restaurantIds = await _seedRestaurants();
      print('✅ Đã tạo ${restaurantIds.length} restaurants\n');

      // 2. Seed Foods cho mỗi restaurant
      print('🍔 Đang tạo foods...');
      int totalFoods = 0;
      for (var restaurantId in restaurantIds) {
        final count = await _seedFoods(restaurantId);
        totalFoods += count;
      }
      print('✅ Đã tạo $totalFoods foods\n');

      // 3. Seed Promos
      print('🎁 Đang tạo promos...');
      final promoCount = await _seedPromos(restaurantIds);
      print('✅ Đã tạo $promoCount promos\n');

      // 4. Seed Orders (giả sử có user IDs)
      print('📦 Đang tạo orders...');
      final orderCount = await _seedOrders(restaurantIds);
      print('✅ Đã tạo $orderCount orders\n');

      // 5. Seed Payments
      print('💰 Đang tạo payments...');
      final paymentCount = await _seedPayments();
      print('✅ Đã tạo $paymentCount payments\n');

      print('🎉 Seed data hoàn tất!');
    } catch (e) {
      print('❌ Lỗi khi seed data: $e');
    }
  }

  // Seed Restaurants
  Future<List<String>> _seedRestaurants() async {
    List<String> restaurantIds = [];

    for (var data in _restaurantData) {
      final docRef = await _firestore.collection('restaurants').add({
        'ownerId': data['ownerId'],
        'name': data['name'],
        'address': data['address'],
        'description': data['description'],
        'imageUrl': data['imageUrl'],
        'status': data['status'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      restaurantIds.add(docRef.id);
      print('  - Đã tạo: ${data['name']}');
    }

    return restaurantIds;
  }

  // Seed Foods
  Future<int> _seedFoods(String restaurantId) async {
    // Lấy tên restaurant để tạo món phù hợp
    final restaurantDoc = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .get();
    final restaurantName = restaurantDoc.data()?['name'] ?? '';

    List<Map<String, dynamic>> foods = [];

    if (restaurantName.contains('Hải Sản')) {
      foods = [
        {
          'name': 'Cơm chiên hải sản đặc biệt',
          'description': 'Cơm chiên với tôm, mực, sò, thơm ngon',
          'price': 85000,
          'category': 'main',
          'imageUrl': 'https://via.placeholder.com/200?text=Com+Chien+HS',
        },
        {
          'name': 'Lẩu hải sản chua cay',
          'description': 'Lẩu hải sản tươi sống, nước lẩu chua cay đậm đà',
          'price': 350000,
          'category': 'main',
          'imageUrl': 'https://via.placeholder.com/200?text=Lau+HS',
        },
        {
          'name': 'Tôm sú nướng muối ớt',
          'description': 'Tôm sú tươi nướng muối ớt thơm lừng',
          'price': 250000,
          'category': 'appetizer',
          'imageUrl': 'https://via.placeholder.com/200?text=Tom+Nuong',
        },
        {
          'name': 'Ghẹ hấp gừng',
          'description': 'Ghẹ tươi hấp với gừng và rau thơm',
          'price': 180000,
          'category': 'appetizer',
          'imageUrl': 'https://via.placeholder.com/200?text=Ghe+Hap',
        },
        {
          'name': 'Nước dừa tươi',
          'description': 'Nước dừa tươi mát lạnh',
          'price': 20000,
          'category': 'drink',
          'imageUrl': 'https://via.placeholder.com/200?text=Dua',
        },
      ];
    } else if (restaurantName.contains('Cơm Tấm')) {
      foods = [
        {
          'name': 'Cơm tấm sườn bì chả',
          'description': 'Cơm tấm truyền thống với sườn nướng, bì, chả',
          'price': 45000,
          'category': 'main',
          'imageUrl': 'https://via.placeholder.com/200?text=Com+Tam+SBC',
        },
        {
          'name': 'Cơm tấm sườn nướng',
          'description': 'Cơm tấm với sườn nướng thơm phức',
          'price': 40000,
          'category': 'main',
          'imageUrl': 'https://via.placeholder.com/200?text=Com+Tam+Suon',
        },
        {
          'name': 'Cơm tấm chả cá',
          'description': 'Cơm tấm với chả cá chiên giòn',
          'price': 38000,
          'category': 'main',
          'imageUrl': 'https://via.placeholder.com/200?text=Com+Tam+Cha',
        },
        {
          'name': 'Trứng ốp la',
          'description': 'Trứng ốp la thêm cho món ăn',
          'price': 8000,
          'category': 'appetizer',
          'imageUrl': 'https://via.placeholder.com/200?text=Trung',
        },
        {
          'name': 'Trà đá',
          'description': 'Trà đá mát lạnh',
          'price': 5000,
          'category': 'drink',
          'imageUrl': 'https://via.placeholder.com/200?text=Tra+Da',
        },
      ];
    } else if (restaurantName.contains('Trà Sữa')) {
      foods = [
        {
          'name': 'Trà sữa trân châu đường đen',
          'description': 'Trà sữa trân châu đường đen thơm ngon, ngọt vừa',
          'price': 35000,
          'category': 'drink',
          'imageUrl': 'https://via.placeholder.com/200?text=Tra+Sua+DD',
        },
        {
          'name': 'Trà sữa matcha',
          'description': 'Trà sữa matcha Nhật Bản, vị đắng nhẹ',
          'price': 38000,
          'category': 'drink',
          'imageUrl': 'https://via.placeholder.com/200?text=Tra+Matcha',
        },
        {
          'name': 'Café sữa đá',
          'description': 'Café phin truyền thống Việt Nam',
          'price': 25000,
          'category': 'drink',
          'imageUrl': 'https://via.placeholder.com/200?text=Ca+Phe',
        },
        {
          'name': 'Sinh tố bơ',
          'description': 'Sinh tố bơ béo ngậy, thơm ngon',
          'price': 30000,
          'category': 'drink',
          'imageUrl': 'https://via.placeholder.com/200?text=Sinh+To+Bo',
        },
        {
          'name': 'Bánh flan',
          'description': 'Bánh flan mềm mịn, ngọt vừa',
          'price': 18000,
          'category': 'dessert',
          'imageUrl': 'https://via.placeholder.com/200?text=Flan',
        },
        {
          'name': 'Combo trà sữa + bánh',
          'description': 'Combo tiết kiệm: 1 trà sữa + 1 bánh tùy chọn',
          'price': 48000,
          'category': 'combo',
          'imageUrl': 'https://via.placeholder.com/200?text=Combo',
        },
      ];
    }

    int count = 0;
    for (var food in foods) {
      await _firestore.collection('foods').add({
        'restaurantId': restaurantId,
        'name': food['name'],
        'description': food['description'],
        'price': food['price'],
        'imageUrl': food['imageUrl'],
        'category': food['category'],
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      count++;
    }

    return count;
  }

  // Seed Promos
  Future<int> _seedPromos(List<String> restaurantIds) async {
    final now = DateTime.now();
    final promos = [
      {
        'code': 'WELCOME10',
        'description': 'Giảm 10% cho đơn hàng đầu tiên',
        'discount': 10,
        'type': 'user',
        'restaurantId': null,
        'startDate': now,
        'endDate': now.add(const Duration(days: 30)),
        'active': true,
        'usedCount': 0,
      },
      {
        'code': 'FREESHIP',
        'description': 'Miễn phí ship cho đơn từ 100k',
        'discount': 0,
        'type': 'user',
        'restaurantId': null,
        'startDate': now,
        'endDate': now.add(const Duration(days: 60)),
        'active': true,
        'usedCount': 0,
      },
      {
        'code': 'FLASHSALE20',
        'description': 'Flash sale giảm 20% trong 24h',
        'discount': 20,
        'type': 'user',
        'restaurantId': null,
        'startDate': now,
        'endDate': now.add(const Duration(hours: 24)),
        'active': true,
        'usedCount': 0,
      },
      // Promo cho restaurant cụ thể
      {
        'code': 'HAISAN15',
        'description': 'Giảm 15% cho món hải sản',
        'discount': 15,
        'type': 'both',
        'restaurantId': restaurantIds.isNotEmpty ? restaurantIds[0] : null,
        'startDate': now,
        'endDate': now.add(const Duration(days: 14)),
        'active': true,
        'usedCount': 0,
      },
    ];

    int count = 0;
    for (var promo in promos) {
      await _firestore.collection('promos').add({
        'code': promo['code'],
        'description': promo['description'],
        'discount': promo['discount'],
        'type': promo['type'],
        'restaurantId': promo['restaurantId'],
        'startDate': Timestamp.fromDate(promo['startDate'] as DateTime),
        'endDate': Timestamp.fromDate(promo['endDate'] as DateTime),
        'active': promo['active'],
        'usedCount': promo['usedCount'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      count++;
    }

    return count;
  }

  // Seed Orders
  Future<int> _seedOrders(List<String> restaurantIds) async {
    if (restaurantIds.isEmpty) return 0;

    // Giả sử có một vài user IDs (thay bằng UID thật)
    final userIds = ['lnAoTclo7kVJluXWbk9M9cPEwu42', 'USER_ID_2', 'USER_ID_3'];

    final statuses = ['pending', 'preparing', 'delivered', 'cancelled'];
    final addresses = [
      '123 Đường Lê Lai, Quận 1, TP.HCM',
      '456 Đường Nguyễn Trãi, Quận 5, TP.HCM',
      '789 Đường Trần Hưng Đạo, Quận 1, TP.HCM',
    ];

    int count = 0;

    // Tạo 10 orders ngẫu nhiên
    for (int i = 0; i < 10; i++) {
      final restaurantId = restaurantIds[i % restaurantIds.length];
      final userId = userIds[i % userIds.length];
      final status = statuses[i % statuses.length];
      final address = addresses[i % addresses.length];

      // Lấy một số foods từ restaurant này
      final foodsSnapshot = await _firestore
          .collection('foods')
          .where('restaurantId', isEqualTo: restaurantId)
          .limit(3)
          .get();

      if (foodsSnapshot.docs.isEmpty) continue;

      final items = foodsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'foodId': doc.id,
          'foodName': data['name'],
          'quantity': (i % 3) + 1,
          'price': data['price'],
        };
      }).toList();

      final totalAmount = items.fold<double>(
        0,
        (sum, item) => sum + (item['price'] as num) * (item['quantity'] as int),
      );

      await _firestore.collection('orders').add({
        'userId': userId,
        'restaurantId': restaurantId,
        'items': items,
        'totalAmount': totalAmount,
        'status': status,
        'deliveryAddress': address,
        'paymentMethod': i % 2 == 0 ? 'cash' : 'card',
        'note': 'Ghi chú đơn hàng ${i + 1}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      count++;
    }

    return count;
  }

  // Seed Payments
  Future<int> _seedPayments() async {
    // Lấy các orders để tạo payments
    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('status', whereIn: ['delivered', 'preparing'])
        .limit(5)
        .get();

    int count = 0;

    for (var orderDoc in ordersSnapshot.docs) {
      final orderData = orderDoc.data();

      await _firestore.collection('payments').add({
        'orderId': orderDoc.id,
        'userId': orderData['userId'],
        'amount': orderData['totalAmount'],
        'method': orderData['paymentMethod'],
        'status': orderData['status'] == 'delivered' ? 'success' : 'pending',
        'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      count++;
    }

    return count;
  }

  // Xóa tất cả data (để test lại)
  Future<void> clearAllData() async {
    print('🗑️ Đang xóa tất cả data...\n');

    final collections = [
      'restaurants',
      'foods',
      'orders',
      'promos',
      'payments',
      'carts',
    ];

    for (var collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('  - Đã xóa collection: $collection');
    }

    print('\n✅ Đã xóa tất cả data!');
  }
}

// Widget để chạy seed data
class SeedDataScreen extends StatelessWidget {
  const SeedDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Firestore Data'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Seed Data vào Firestore',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                final seeder = FirestoreSeedData();
                await seeder.seedAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Seed data thành công!')),
                  );
                }
              },
              icon: const Icon(Icons.upload),
              label: const Text('Seed All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final seeder = FirestoreSeedData();
                await seeder.clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã xóa tất cả data!')),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
