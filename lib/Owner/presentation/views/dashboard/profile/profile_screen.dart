import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/restaurant_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/config/routes.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.userId;

      if (userId != null) {
        final restaurantController = Get.find<RestaurantController>();
        await restaurantController.loadRestaurantByOwnerId(userId);
      } else {
        print('No user ID found');
      }
    } catch (e) {
      print('Error in _loadData: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GetBuilder<RestaurantController>(
        builder: (controller) {
          final restaurant = controller.restaurant;
          final isLoading = controller.isLoading;
          final error = controller.error;

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (error != null) {
            return _buildErrorState(controller, error);
          }

          if (restaurant == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: primaryColor,
            child: CustomScrollView(
              slivers: [
                // ===== HEADER WITH IMAGE =====
                SliverToBoxAdapter(child: _buildHeader(restaurant)),

                // ===== CONTENT =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Restaurant Info Card
                        _buildInfoCard(restaurant),
                        const SizedBox(height: 16),

                        // Quick Stats
                        _buildStatsCard(restaurant),
                        const SizedBox(height: 16),

                        // Action Menu
                        _buildActionsCard(restaurant),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(dynamic restaurant) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Thông tin quán',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Refresh button
                  IconButton(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Restaurant Logo & Name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  // Logo
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ownerEditProfileRoute,
                        arguments: restaurant,
                      ).then((result) {
                        // Only reload if update was successful and we need to refresh
                        // updateRestaurant already reloads data, so we just need to ensure UI updates
                        if (result == true) {
                          // Small delay to ensure updateRestaurant has finished
                          Future.delayed(const Duration(milliseconds: 100), () {
                            final userId =
                                Get.find<AuthController>().currentUser?.userId;
                            if (userId != null) {
                              Get.find<RestaurantController>()
                                  .loadRestaurantByOwnerId(userId, force: true);
                            }
                          });
                        }
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: restaurant.imageUrl.isNotEmpty
                            ? Image.network(
                                restaurant.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.store,
                                  size: 40,
                                  color: primaryColor,
                                ),
                              )
                            : const Icon(
                                Icons.store,
                                size: 40,
                                color: primaryColor,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Rating
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: restaurant.status == 'open'
                                    ? Colors.green.withOpacity(0.8)
                                    : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                restaurant.status == 'open'
                                    ? 'Mở cửa'
                                    : 'Đóng cửa',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(dynamic restaurant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin cơ bản',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone
          _buildInfoItem(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: restaurant.phone.isNotEmpty
                ? restaurant.phone
                : 'Chưa cập nhật',
            color: Colors.blue,
          ),
          const Divider(height: 24),

          // Address
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ',
            value: restaurant.address,
            color: Colors.orange,
          ),
          const Divider(height: 24),

          // Description
          _buildInfoItem(
            icon: Icons.description_outlined,
            label: 'Mô tả',
            value: restaurant.description.isNotEmpty
                ? restaurant.description
                : 'Chưa cập nhật mô tả',
            color: Colors.purple,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value.contains('Chưa')
                      ? Colors.grey.shade400
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(dynamic restaurant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.star,
              value: restaurant.rating.toStringAsFixed(1),
              label: 'Đánh giá',
              color: Colors.amber,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              icon: Icons.restaurant_menu,
              value: '-',
              label: 'Đơn hàng',
              color: primaryColor,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              icon: restaurant.status == 'open'
                  ? Icons.check_circle
                  : Icons.cancel,
              value: restaurant.status == 'open' ? 'Mở' : 'Đóng',
              label: 'Trạng thái',
              color: restaurant.status == 'open' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildActionsCard(dynamic restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit_outlined,
            title: 'Chỉnh sửa thông tin',
            subtitle: 'Cập nhật tên, địa chỉ, mô tả...',
            color: primaryColor,
            onTap: () {
              Navigator.pushNamed(
                context,
                ownerEditProfileRoute,
                arguments: restaurant,
              ).then((result) {
                // Only reload if update was successful and we need to refresh
                // updateRestaurant already reloads data, so we just need to ensure UI updates
                if (result == true) {
                  // Small delay to ensure updateRestaurant has finished
                  Future.delayed(const Duration(milliseconds: 100), () {
                    final userId =
                        Get.find<AuthController>().currentUser?.userId;
                    if (userId != null) {
                      Get.find<RestaurantController>().loadRestaurantByOwnerId(
                        userId,
                        force: true,
                      );
                    }
                  });
                }
              });
            },
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          _buildActionTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu đăng nhập',
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, ownerChangePasswordRoute);
            },
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          _buildActionTile(
            icon: Icons.logout,
            title: 'Đăng xuất',
            subtitle: 'Thoát khỏi tài khoản',
            color: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color == Colors.red ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }

  Widget _buildErrorState(RestaurantController controller, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không thể tải thông tin quán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_outlined,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không tìm thấy thông tin quán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng liên hệ quản trị viên',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final navigator = Navigator.of(context);
    final authController = Get.find<AuthController>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authController.signOut();
              navigator.pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
