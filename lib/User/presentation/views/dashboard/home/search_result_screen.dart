import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/User/presentation/widgets/widgets.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/services/food/food_service.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/assets.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/config/routes.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FoodService _foodService = Get.find<FoodService>();
  String? _selectedCategory;
  bool _searchNameOnly = true; // Mặc định tìm chỉ theo tên
  final List<String> _categories = [
    'Tất cả',
    'Món chính',
    'Món phụ',
    'Đồ uống',
    'Tráng miệng',
    'Món ăn vặt',
  ];

  @override
  void initState() {
    super.initState();
    // Reset về tất cả món ăn khi vào màn hình
    _foodService.clearFilters();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty && _selectedCategory == null) {
      _foodService.clearFilters();
      return;
    }

    _foodService.searchFoods(query.trim(), nameOnly: _searchNameOnly);
    
    // Lọc thêm theo category nếu có
    if (_selectedCategory != null && _selectedCategory != 'Tất cả') {
      _filterByCategory(_selectedCategory!);
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    
    if (category == 'Tất cả') {
      if (_searchController.text.trim().isEmpty) {
        _foodService.clearFilters();
      } else {
        _foodService.searchFoods(_searchController.text.trim());
      }
    } else {
      _foodService.filterByCategory(category);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _foodService.clearFilters();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () {
            _foodService.clearFilters();
            Navigator.pop(context);
          },
        ),
        title: SearchTextField(
          controller: _searchController,
          autofocus: true,
          hintText: 'Tìm kiếm món ăn...',
          onChanged: (value) {
            // Tìm kiếm real-time khi gõ
            _performSearch(value);
          },
          onSubmitted: (value) {
            _performSearch(value);
          },
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Search options
          Container(
            color: whiteColor,
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(Icons.tune, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Tìm kiếm:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      _buildSearchOption('Chỉ tên', true),
                      const SizedBox(width: 8),
                      _buildSearchOption('Tất cả', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Category filter chips
          Container(
            height: 50,
            color: whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'Tất cả');
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => _filterByCategory(category),
                    backgroundColor: Colors.grey[100],
                    selectedColor: primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? primaryColor : Colors.transparent,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          
          // Search results
          Expanded(
            child: GetBuilder<FoodService>(
              builder: (foodService) {
                if (foodService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                final foodList = _searchController.text.trim().isEmpty
                    ? foodService.foods
                    : foodService.filteredFoods;

                if (foodList.isEmpty) {
                  return _SearchNotFound(
                    searchQuery: _searchController.text.trim(),
                  );
                }

                return _SearchFound(
                  foodList: foodList,
                  searchQuery: _searchController.text.trim(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOption(String label, bool isNameOnly) {
    final isSelected = _searchNameOnly == isNameOnly;
    
    return InkWell(
      onTap: () {
        setState(() {
          _searchNameOnly = isNameOnly;
        });
        // Thực hiện lại tìm kiếm với option mới
        if (_searchController.text.trim().isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? whiteColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SearchFound extends StatelessWidget {
  final List<FoodModel> foodList;
  final String searchQuery;

  const _SearchFound({
    required this.foodList,
    required this.searchQuery,
  });

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
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    searchQuery.isEmpty
                        ? 'Tất cả món ăn (${foodList.length})'
                        : 'Tìm thấy ${foodList.length} kết quả cho "$searchQuery"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
  final String searchQuery;

  const _SearchNotFound({required this.searchQuery});

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
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.search_off,
                  size: 120,
                  color: Colors.grey[400],
                );
              },
            ),
            YBox(20),
            Text(
              searchQuery.isEmpty
                  ? 'Chưa có món ăn nào'
                  : FoodieStrings.searchNotFound,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            YBox(10),
            Text(
              searchQuery.isEmpty
                  ? 'Hệ thống chưa có món ăn nào.\nVui lòng quay lại sau!'
                  : 'Không tìm thấy món ăn với từ khóa "$searchQuery".\nThử tìm kiếm với từ khóa khác!',
              style: TextStyle(fontSize: 17, color: greyColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
