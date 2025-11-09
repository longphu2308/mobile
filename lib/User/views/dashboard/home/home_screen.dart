import 'package:flutter/material.dart';
import 'package:mobile/User/models/food.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:mobile/User/views/dashboard/home/search_result_screen.dart';
import 'package:mobile/User/views/dashboard/cart/cart_screen.dart';
import 'package:mobile/User/services/cart_service.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _index = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  Consumer<CartService>(
                    builder: (context, cartService, child) {
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            },
                          ),
                          if (cartService.itemCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cartService.itemCount}',
                                  style: const TextStyle(
                                    color: whiteColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
                controller: _tabController,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  ...List.generate(10, (index) {
                    final foods = Food.foodList;
                    final demoFood = foods[index % foods.length];
                    return _FoodEntry(
                      food: demoFood,
                      tag: 'image_tag$index',
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 100), // Thêm space ở cuối để không bị che bởi bottom nav
          ],
        ),
      ),
    );
  }
}

class _FoodEntry extends StatelessWidget {
  final Food food;
  final String tag;

  const _FoodEntry({super.key, required this.food, required this.tag});

  String _formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    if (priceStr.length > 3) {
      return priceStr.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return priceStr;
  }

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular image
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
            const SizedBox(height: 15),
            // Food name
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
            // Price
            Text(
              _formatPrice(food.price),
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}