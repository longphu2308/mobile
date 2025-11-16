import 'package:flutter/material.dart';
import 'package:mobile/User/models/food.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:mobile/User/views/dashboard/home/search_result_screen.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/providers/cart_provider.dart';
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () {
                                Navigator.pushNamed(context, cartRoute);
                              },
                            ),
                            if (cartProvider.itemCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, cartRoute);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${cartProvider.itemCount}',
                                        style: const TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
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
            SizedBox(
              height: 280,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  // Chặn tất cả scroll notification từ ListView ngang để không ảnh hưởng đến scroll dọc
                  return true;
                },
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  physics: const BouncingScrollPhysics(),
                  itemCount: 10,
                  separatorBuilder: (context, index) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final foodIndex = index % Food.foodList.length;
                    final demoFood = Food.foodList[foodIndex];
                    return _FoodEntry(
                      food: demoFood,
                      tag: 'image_tag$index',
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 100), // Thêm space ở cuối để không bị che bởi bottom nav
            ],
          ),
        ),
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
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        foodDetailRoute,
        arguments: {'food': food, 'tag': tag},
      ),
      child: Container(
        width: 220,
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