import 'package:flutter/material.dart';
import 'package:mobile/User/models/food.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:provider/provider.dart';

class FoodDetail extends StatefulWidget {
  final Food food;
  final String tag;

  const FoodDetail({super.key, required this.food, required this.tag});

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  late PageController _pageController;
  final int _numOfPages = 4;
  int _currentPage = 0;

  final TextStyle _helperStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  final TextStyle _contentStyle = TextStyle(
    fontSize: 15,
    color: greyColor,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: blackColor,
            ),
        iconTheme: IconThemeData(
          color: blackColor,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: horizontalPadding,
            ),
            child: Consumer<FoodieStore>(
              builder: (context, store, _) {
                final isFavorite = store.isFavorite(widget.food);
                return IconButton(
                  onPressed: () => store.toggleFavorite(widget.food),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                    color: isFavorite ? primaryColor : blackColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding).add(
          EdgeInsets.only(
            bottom: verticalPadding,
          ),
        ),
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
                    setState(
                      () => _currentPage = value,
                    );
                  },
                  children: [
                    ...List.generate(
                      4,
                      (index) => Image.asset(
                        widget.food.assetSrc,
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
              children: [
                ..._buildPageIndicator(),
              ],
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
                '${formatCurrency(widget.food.price)} đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
            YBox(30),
            Text(
              FoodieStrings.description,
              style: _helperStyle,
            ),
            YBox(5),
            Text(
              FoodieStrings.descriptionContent,
              style: _contentStyle,
            ),
            YBox(20),
            Text(
              FoodieStrings.returnPolicyHelper,
              style: _helperStyle,
            ),
            YBox(5),
            Text(
              FoodieStrings.returnPolicy,
              style: _contentStyle,
            ),

            Spacer(),

            FoodieButton(
              text: FoodieStrings.addToCart,
              onPressed: () {
                context.read<FoodieStore>().addToCart(widget.food);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.food.name} đã thêm vào giỏ'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}