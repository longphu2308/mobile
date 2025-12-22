import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/User/presentation/widgets/widgets.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/favorite_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
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
  bool _isFavorited = false;
  bool _isCheckingFavorite = true;
  bool _isLoadingRestaurant = true;

  RestaurantModel? _restaurant;
  LatLng? _restaurantLocation;
  final MapController _mapController = MapController();
  final _restaurantRepository = RestaurantRepository();

  final TextStyle _helperStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  final TextStyle _contentStyle = TextStyle(fontSize: 15, color: greyColor);

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadRestaurantInfo();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantInfo() async {
    if (widget.food.restaurantId.isEmpty) {
      setState(() => _isLoadingRestaurant = false);
      return;
    }

    try {
      final restaurant = await _restaurantRepository.getRestaurantById(
        widget.food.restaurantId,
      );

      if (mounted) {
        setState(() {
          _restaurant = restaurant;
          if (restaurant != null) {
            // Get location from restaurant if available
            // Note: RestaurantModel doesn't have lat/lng, so we'll need to fetch separately
            _loadRestaurantLocation(restaurant.id);
          }
          _isLoadingRestaurant = false;
        });
      }
    } catch (e) {
      print('Error loading restaurant: $e');
      if (mounted) {
        setState(() => _isLoadingRestaurant = false);
      }
    }
  }

  Future<void> _loadRestaurantLocation(String restaurantId) async {
    try {
      final supabase = SupabaseService().client;
      final data = await supabase
          .from('restaurants')
          .select('latitude, longitude')
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (data != null && mounted) {
        final lat = (data['latitude'] as num?)?.toDouble();
        final lon = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          setState(() {
            _restaurantLocation = LatLng(lat, lon);
          });
          // Fit map to restaurant location after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _restaurantLocation != null) {
              _mapController.move(_restaurantLocation!, 15);
            }
          });
        }
      }
    } catch (e) {
      print('Error loading restaurant location: $e');
    }
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
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Hero(
                          tag: widget.tag,
                          child: Image.network(
                            widget.food.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[200]!,
                                      Colors.grey[300]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant_rounded,
                                    color: Colors.grey,
                                    size: 64,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    YBox(24),

                    // Food name
                    Text(
                      widget.food.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    YBox(12),
                    // Price
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          '${_formatPrice(widget.food.price)} đ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    YBox(32),
                    // Description section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                FoodieStrings.description,
                                style: _helperStyle.copyWith(color: blackColor),
                              ),
                            ],
                          ),
                          YBox(12),
                          Text(
                            widget.food.description.isNotEmpty
                                ? widget.food.description
                                : FoodieStrings.descriptionContent,
                            style: _contentStyle.copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    YBox(20),
                    // Restaurant info section
                    if (_restaurant != null) _buildRestaurantInfo(),
                    YBox(20),
                    // Map section
                    if (_restaurantLocation != null) _buildMap(),
                    YBox(20),
                    // Return policy section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                FoodieStrings.returnPolicyHelper,
                                style: _helperStyle.copyWith(
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                          YBox(12),
                          Text(
                            FoodieStrings.returnPolicy,
                            style: _contentStyle.copyWith(
                              color: Colors.blue[800],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  restaurantName: _restaurant?.name ?? '',
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

  Widget _buildRestaurantInfo() {
    if (_isLoadingRestaurant) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_restaurant == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              // Restaurant logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _restaurant!.imageUrl.isNotEmpty
                      ? Image.network(
                          _restaurant!.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Restaurant name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _restaurant!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_restaurant!.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _restaurant!.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_restaurant!.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _restaurant!.phone,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_restaurantLocation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _restaurantLocation!,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mobile',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _restaurantLocation!,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
