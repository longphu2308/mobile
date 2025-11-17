import 'package:flutter/material.dart';
import 'package:mobile/User/models/food.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/assets.dart';
import 'package:mobile/User/utils/strings.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchString;
  final List<Food> foundFoodList;

  const SearchResultScreen({
    super.key,
    required this.searchString,
    required this.foundFoodList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            style: const TextStyle(color: blackColor),
            decoration: InputDecoration(
              hintText: searchString,
              hintStyle: const TextStyle(color: blackColor),
              border: InputBorder.none,
            ),
          ),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: blackColor,
            ),
      ),
      body: foundFoodList.isNotEmpty
          ? _SearchFound(
              foodList: foundFoodList,
            )
          : _SearchNotFound(),
    );
  }
}

class _SearchFound extends StatelessWidget {
  final List<Food> foodList;

  const _SearchFound({required this.foodList});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: Column(
        children: [
          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Text(
              FoodieStrings.foundResults.replaceAll('%d', '${foodList.length}'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final food = foodList[index];
                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    foodDetailRoute,
                    arguments: {'food': food, 'tag': 'search_${food.name}_$index'},
                  ),
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Circular image
                        ClipOval(
                          child: Image.asset(
                            food.assetSrc,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Food name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Price
                        Text(
                          '${formatCurrency(food.price)} đ',
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              FoodieAssets.notFound,
            ),
            YBox(20),
            Text(
              FoodieStrings.searchNotFound,
              style: TextStyle(
                fontSize: 28,
              ),
            ),
            YBox(10),
            Text(
              FoodieStrings.searchNotFoundHint,
              style: TextStyle(
                fontSize: 17,
                color: greyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}