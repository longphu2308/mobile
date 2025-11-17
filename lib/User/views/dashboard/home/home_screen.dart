import 'package:flutter/material.dart';
import 'package:mobile/User/models/food.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:mobile/User/views/dashboard/home/search_result_screen.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với menu và cart icon
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {},
                    ),
                    Consumer<FoodieStore>(
                      builder: (context, store, _) {
                        final cartCount = store.totalCartItems;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () =>
                                  Navigator.pushNamed(context, cartRoute),
                            ),
                            if (cartCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  FoodieStrings.hSHeading,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            YBox(40),
            SearchTextField(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultScreen(
                      searchString: 'Search',
                      foundFoodList: Food.foodList,
                    ),
                  ),
                );
              },
            ),
            YBox(40),
            Padding(
              padding: const EdgeInsets.only(left: horizontalPadding),
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _index = index;
                  });
                },
                isScrollable: true,
                indicatorColor: primaryColor,
                labelColor: primaryColor,
                unselectedLabelColor: greyColor,
                tabs: [
                  ...List.generate(
                    5,
                    (index) => Tab(
                      text: tabBarTitle[index],
                    ),
                  ),
                ],
              ),
            ),
            YBox(25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(), // Spacer bên trái
                  Text(
                    FoodieStrings.seeMore,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            YBox(15),
            Builder(
              builder: (context) {
                final selectedCategory = tabBarTitle[_index];
                List<Food> foods = Food.foodList
                    .where((food) => food.foodCategory == selectedCategory)
                    .toList();
                if (foods.isEmpty) {
                  foods = Food.foodList;
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Row(
                    children: [
                      ...List.generate(foods.length, (index) {
                        final food = foods[index];
                        return _FoodEntry(
                          food: food,
                          tag: 'image_tag${food.name}_$index',
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 100), // Thêm space ở cuối để không bị che bởi bottom nav
          ],
        ),
      ),
      ),
    );
  }
}

class _FoodEntry extends StatelessWidget {
  final Food food;
  final String tag;

  const _FoodEntry({required this.food, required this.tag});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodieStore>();
    final isFavorite = store.isFavorite(food);

    return InkWell(
      splashColor: transparentColor,
      highlightColor: transparentColor,
      onTap: () => Navigator.pushNamed(
        context,
        foodDetailRoute,
        arguments: {'food': food, 'tag': tag},
      ),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Hero(
                  tag: tag,
                  child: ClipOval(
                    child: Image.asset(
                      food.assetSrc,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? primaryColor : Colors.grey[500],
                    ),
                    onPressed: () => store.toggleFavorite(food),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${formatCurrency(food.price)} đ',
              style: const TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: TextButton.icon(
                onPressed: () {
                  store.addToCart(food);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${food.name} đã thêm vào giỏ'),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}