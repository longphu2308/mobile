import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/widgets/widgets.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/favorite_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:get/get.dart';

class FoodDetail extends StatefulWidget {
  final FoodModel food;
  final String tag;

  const FoodDetail({super.key, required this.food, required this.tag});

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  late PageController _pageController;
  final int _numOfPages = 4;
  int _currentPage = 0;
  bool _isFavorited = false;
  bool _isCheckingFavorite = true;

  final TextStyle _helperStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  final TextStyle _contentStyle = TextStyle(fontSize: 15, color: greyColor);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authController = Get.find<AuthController>();
    final favoriteController = Get.find<FavoriteController>();

    if (authController.currentUser == null) {
      setState(() {
        _isCheckingFavorite = false;
        _isFavorited = false;
      });
      return;
    }

    favoriteController.setUserId(authController.currentUser!.userId);
    final isFavorited = await favoriteController.isFavorited(widget.food.id);

    if (mounted) {
      setState(() {
        _isFavorited = isFavorited;
        _isCheckingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final authController = Get.find<AuthController>();
    final favoriteController = Get.find<FavoriteController>();

    if (authController.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add favorites'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    favoriteController.setUserId(authController.currentUser!.userId);

    setState(() {
      _isFavorited = !_isFavorited;
    });

    final success = _isFavorited
        ? await favoriteController.addFavorite(widget.food)
        : await favoriteController.removeFavorite(widget.food.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: primaryColor,
        ),
      );
    } else {
      // Revert state on failure
      setState(() {
        _isFavorited = !_isFavorited;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favoriteController.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numOfPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : greyColor,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgColor,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: blackColor),
        iconTheme: IconThemeData(color: blackColor),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: horizontalPadding),
            child: _isCheckingFavorite
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      _isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      color: _isFavorited ? primaryColor : blackColor,
                    ),
                    onPressed: _toggleFavorite,
                    tooltip: _isFavorited
                        ? 'Xóa khỏi yêu thích'
                        : 'Thêm vào yêu thích',
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ).add(EdgeInsets.only(top: 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: Hero(
                        tag: widget.tag,
                        child: PageView(
                          onPageChanged: (value) {
                            setState(() => _currentPage = value);
                          },
                          children: [
                            ...List.generate(
                              4,
                              (index) => Image.network(
                                widget.food.imageUrl,
                                fit: BoxFit.fitHeight,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                        size: 48,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // page view indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [..._buildPageIndicator()],
                    ),

                    YBox(30),

                    Align(
                      child: Text(
                        widget.food.name,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      child: Text(
                        _formatPrice(widget.food.price),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    YBox(30),
                    Text(FoodieStrings.description, style: _helperStyle),
                    YBox(5),
                    Text(
                      FoodieStrings.descriptionContent,
                      style: _contentStyle,
                    ),
                    YBox(20),
                    Text(FoodieStrings.returnPolicyHelper, style: _helperStyle),
                    YBox(5),
                    Text(FoodieStrings.returnPolicy, style: _contentStyle),
                    YBox(30),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ).add(EdgeInsets.only(bottom: verticalPadding, top: 16)),
            child: FoodieButton(
              text: 'Thêm vào giỏ hàng',
              onPressed: () {
                final cartController = Get.find<CartController>();
                cartController.addItem(
                  widget.food,
                  restaurantId: widget.food.restaurantId,
                  restaurantName: '', // TODO: Get restaurant name
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.food.name} đã được thêm vào giỏ hàng',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: primaryColor,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
