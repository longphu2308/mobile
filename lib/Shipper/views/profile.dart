import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/config/routes.dart';
import 'package:mobile/Shipper/widgets/shipper_bottom_nav.dart';

class ShipperProfile extends StatefulWidget {
  static const routeName = '/shipper/profile';
  const ShipperProfile({super.key});

  @override
  State<ShipperProfile> createState() => _ShipperProfileState();
}

class _ShipperProfileState extends State<ShipperProfile> {
  bool isLoading = true;
  Map<String, dynamic> userProfile = {};
  Map<String, dynamic> shipperProfile = {};

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => isLoading = true);
    final supabase = SupabaseService();
    final uid = supabase.userId;
    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final up = await supabase.from('user_profiles').select().eq('user_id', uid).maybeSingle();
      final sp = await supabase.from('shipper_profiles').select().eq('user_id', uid).maybeSingle();
      setState(() {
        userProfile = up ?? <String, dynamic>{};
        shipperProfile = sp ?? <String, dynamic>{};
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showEditDialog() async {
    final fullNameCtrl = TextEditingController(text: userProfile['full_name'] ?? '');
    final phoneCtrl = TextEditingController(text: userProfile['phone'] ?? '');
    final vehicleTypeCtrl = TextEditingController(text: shipperProfile['vehicle_type'] ?? '');
    final plateCtrl = TextEditingController(text: shipperProfile['vehicle_plate'] ?? '');
    final licenseCtrl = TextEditingController(text: shipperProfile['license_number'] ?? '');
    bool available = (shipperProfile['is_available'] == true);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (c, setC) {
        final dialogWidth = MediaQuery.of(ctx).size.width * 0.95;
        return AlertDialog(
          title: const Text('Chỉnh sửa thông tin'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên')),
                  const SizedBox(height: 8),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 8),
                  TextField(controller: vehicleTypeCtrl, decoration: const InputDecoration(labelText: 'Loại phương tiện (bike/motorbike/car)')),
                  const SizedBox(height: 8),
                  TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Biển số')),
                  const SizedBox(height: 8),
                  TextField(controller: licenseCtrl, decoration: const InputDecoration(labelText: 'Bằng lái')),
                  
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                final supabase = SupabaseService();
                final uid = supabase.userId;
                if (uid == null) return;
                final upMap = {
                  'user_id': uid,
                  'full_name': fullNameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                };
                final spMap = {
                  'user_id': uid,
                  'vehicle_type': vehicleTypeCtrl.text.trim(),
                  'vehicle_plate': plateCtrl.text.trim(),
                  'license_number': licenseCtrl.text.trim(),
                  'is_available': available,
                };

                try {
                  // Upsert user profile
                  if ((userProfile['profile_id'] ?? '').toString().isNotEmpty) {
                    await supabase.from('user_profiles').update(upMap).eq('user_id', uid);
                  } else {
                    await supabase.from('user_profiles').insert(upMap);
                  }

                  // Upsert shipper profile
                  if ((shipperProfile['shipper_profile_id'] ?? '').toString().isNotEmpty) {
                    await supabase.from('shipper_profiles').update(spMap).eq('user_id', uid);
                  } else {
                    await supabase.from('shipper_profiles').insert(spMap);
                  }

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                  await _loadProfiles();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (userProfile['full_name'] ?? 'Người giao hàng').toString();
    final vehicle = shipperProfile.isNotEmpty ? '${shipperProfile['vehicle_type'] ?? ''} • Plate: ${shipperProfile['vehicle_plate'] ?? ''}' : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 44,
                      child: Text(displayName.isNotEmpty ? displayName[0] : '?', style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 6),
                  if (vehicle.isNotEmpty) Center(child: Text(vehicle)),
                  const SizedBox(height: 12),

                  // Vertical action buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _showEditDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          child: const Text('Chỉnh sửa'),
                        ),
                      ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, authRoute, (route) => false),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    child: const Text('Đăng xuất'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          final _oldCtrl = TextEditingController();
                          final _newCtrl = TextEditingController();
                          final _confirmCtrl = TextEditingController();
                          return StatefulBuilder(builder: (c, setState) {
                            final dialogWidth = MediaQuery.of(ctx).size.width * 0.95;
                            return AlertDialog(
                              title: const Text('Đổi mật khẩu'),
                              content: SingleChildScrollView(
                                child: SizedBox(
                                  width: dialogWidth,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextField(controller: _oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu cũ')),
                                      const SizedBox(height: 8),
                                      TextField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
                                      const SizedBox(height: 8),
                                      TextField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới')),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                  onPressed: () async {
                                    final old = _oldCtrl.text.trim();
                                    final newPassword = _newCtrl.text.trim();
                                    final confirmPassword = _confirmCtrl.text.trim();
                                    if (newPassword.isEmpty || confirmPassword.isEmpty || old.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin')));
                                      return;
                                    }
                                    if (newPassword != confirmPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp')));
                                      return;
                                    }

                                    final supabase = SupabaseService();
                                    try {
                                      // Attempt to update password for current user
                                      final res = await supabase.auth.updateUser(UserAttributes(password: newPassword));
                                      if (res.user != null) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu đã được đổi')));
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể đổi mật khẩu')));
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi đổi mật khẩu')));
                                    }
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          });
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    child: const Text('Đổi mật khẩu'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Mock stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard('Rating', '4.8', Icons.star, Colors.amber),
                _statCard('Completed', '124', Icons.check_circle, Colors.green),
                _statCard(
                  'Earnings',
                  '12,500,000',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Recent deliveries',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            FutureBuilder<List<ShipperOrder>>(
              future: ShipperOrder.fetchAssignedOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final recent = snapshot.data ?? [];
                if (recent.isEmpty) return const Text('No recent deliveries');
                return Column(
                  children: recent.map((r) {
                    return Card(
                      child: ListTile(
                        title: Text('${r.id} • ${r.customerName}'),
                        subtitle: Text('${r.address}'),
                        trailing: Text('${r.total.toInt()} VND'),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/shipper/order-detail',
                          arguments: r,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: shipperBottomNav(context, 2),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
