import 'package:flutter/material.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodieStore>(
      builder: (context, store, _) {
        if (store.favoriteFoods.isEmpty) {
          return const _EmptyFavorites();
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20,
          ),
          itemCount: store.favoriteFoods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final food = store.favoriteFoods[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ],
              ),
              child: ListTile(
                leading: ClipOval(
                  child: Image.asset(
                    food.assetSrc,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood),
                      );
                    },
                  ),
                ),
                title: Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${formatCurrency(food.price)} đ',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => store.toggleFavorite(food),
                      icon: const Icon(Icons.favorite),
                      color: primaryColor,
                    ),
                    IconButton(
                      onPressed: () {
                        store.addToCart(food);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${food.name} đã thêm vào giỏ'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 96,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có món yêu thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Nhấn vào biểu tượng trái tim trong trang món ăn để lưu lại những món bạn thích.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


