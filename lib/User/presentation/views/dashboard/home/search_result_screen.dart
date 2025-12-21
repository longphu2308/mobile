import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/widgets/widgets.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/services/food/food_service.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/assets.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/config/routes.dart';
import 'package:get/get.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchString;
  final List<FoodModel> foundFoodList;

  const SearchResultScreen({
    super.key,
    required this.searchString,
    required this.foundFoodList,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late TextEditingController _searchController;
  List<FoodModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false; // Track if user has performed a search

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchString == 'Search' ? '' : widget.searchString);
    _searchResults = widget.foundFoodList;
    // If initial searchString is not empty and not 'Search', perform initial search
    if (widget.searchString.isNotEmpty && widget.searchString != 'Search') {
      _performSearch(widget.searchString);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = widget.foundFoodList;
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final foodService = Get.find<FoodService>();
      await foodService.searchFoods(trimmedQuery);
      setState(() {
        _searchResults = foodService.filteredFoods;
        _isSearching = false;
      });
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

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
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: blackColor),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: const TextStyle(color: blackColor),
              border: InputBorder.none,
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search, color: blackColor),
                      onPressed: () => _performSearch(_searchController.text),
                    ),
            ),
            onSubmitted: (value) => _performSearch(value),
            onChanged: (value) {
              // Real-time search as user types (debounced)
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  _performSearch(value);
                }
              });
            },
          ),
        ),
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: blackColor),
      ),
      body: _isSearching
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            )
          : _searchResults.isNotEmpty
              ? _SearchFound(foodList: _searchResults)
              : _hasSearched
                  ? _SearchNotFound()
                  : _SearchFound(foodList: widget.foundFoodList),
    );
  }
}

class _SearchFound extends StatelessWidget {
  final List<FoodModel> foodList;

  const _SearchFound({required this.foodList});

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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
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
                    arguments: {
                      'food': food,
                      'tag': 'search_${food.name}_$index',
                    },
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
                          child: Image.network(
                            food.imageUrl,
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
                          _formatPrice(food.price),
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
            // Use Icon instead of Image.asset to avoid asset loading errors
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            YBox(20),
            Text(
              FoodieStrings.searchNotFound,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            YBox(10),
            Text(
              FoodieStrings.searchNotFoundHint,
              style: TextStyle(fontSize: 17, color: greyColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
