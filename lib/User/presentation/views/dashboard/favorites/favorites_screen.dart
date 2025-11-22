import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/controllers/favorite_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  void _loadFavorites() {
    final authController =
        Provider.of<AuthController>(context, listen: false);
    final favoriteController =
        Provider.of<FavoriteController>(context, listen: false);

    if (authController.currentUser != null) {
      favoriteController.setUserId(authController.currentUser!.userId);
      favoriteController.loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: const Text(
          'Yêu thích',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<FavoriteController, AuthController>(
        builder: (context, favoriteController, authController, child) {
          if (authController.currentUser == null) {
            return const Center(
              child: Text('Vui lòng đăng nhập để xem danh sách yêu thích'),
            );
          }

          if (favoriteController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    favoriteController.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavorites,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (favoriteController.favoriteRestaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhà hàng yêu thích',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm nhà hàng vào yêu thích để xem ở đây',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await favoriteController.loadFavorites();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(horizontalPadding),
              itemCount: favoriteController.favoriteRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant =
                    favoriteController.favoriteRestaurants[index];
                return _RestaurantCard(
                  restaurant: restaurant,
                  onRemove: () async {
                    final success = await favoriteController
                        .removeFavorite(restaurant.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xóa khỏi yêu thích'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onRemove;

  const _RestaurantCard({
    required this.restaurant,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Restaurant Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
            ),
            child: Image.network(
              restaurant.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.grey[600],
                    size: 40,
                  ),
                );
              },
            ),
          ),
          // Restaurant Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: greyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (restaurant.status == 'open')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Đang mở',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Remove Button
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: primaryColor,
            ),
            onPressed: onRemove,
            tooltip: 'Xóa khỏi yêu thích',
          ),
        ],
      ),
    );
  }
}

