import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/ui/widgets/widgets.dart';
import 'package:mobile/utils/utils.dart';
import 'package:mobile/utils/strings.dart';
import 'package:mobile/ui/widgets/foodie_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: primaryColorDark,
        body: Stack(
          children: [
            // Background image placeholder - có thể thêm ảnh sau
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      primaryColorDark.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 73,
                    width: 73,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: whiteColor,
                    ),
                    child: Center(
                      child: SizedBox(
                        height: 55,
                        width: 55,
                        child: FoodieLogo(),
                      ),
                    ),
                  ),
                  YBox(30),
                  Text(
                    FoodieStrings.wSHeading,
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 55,
                    ),
                  ),
                  Spacer(),
                  FoodieButton(
                    text: FoodieStrings.getStarted,
                    onPressed: () => Navigator.pushNamed(context, authRoute),
                    isPainted: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}