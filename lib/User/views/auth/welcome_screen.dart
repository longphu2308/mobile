import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/views/widgets/foodie_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColorDark, // Đỏ đậm ở trên
                primaryColor, // Cam đậm ở giữa
                orangeLight, // Cam nhạt ở dưới
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Nhân vật 3D placeholder ở phần dưới
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nhân vật 1 - nổi bật nhất bên trái
                      _buildCharacterPlaceholder(
                        color: Colors.brown[700]!,
                        hasGlasses: true,
                        hasRainbowHair: true,
                      ),
                      const SizedBox(width: 20),
                      // Nhân vật 2 - giữa (bị che một phần)
                      _buildCharacterPlaceholder(
                        color: Colors.brown[600]!,
                        hasBeard: true,
                        isSmall: true,
                      ),
                      const SizedBox(width: 15),
                      // Nhân vật 3 - phải (bị che nhiều)
                      _buildCharacterPlaceholder(
                        color: Colors.brown[500]!,
                        isSmall: true,
                      ),
                    ],
                  ),
                ),
                // Nội dung chính
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo ở góc trên trái
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
                      const SizedBox(height: 40),
                      // Tiêu đề "Food for Everyone" - 2 dòng
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: whiteColor,
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          children: const [
                            TextSpan(text: 'Food for\n'),
                            TextSpan(text: 'Everyone'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Nút "Get started" - nền trắng, chữ cam
                      _WelcomeButton(
                        text: FoodieStrings.getStarted,
                        onPressed: () => Navigator.pushNamed(context, authRoute),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterPlaceholder({
    required Color color,
    bool hasGlasses = false,
    bool hasBeard = false,
    bool hasRainbowHair = false,
    bool isSmall = false,
  }) {
    final size = isSmall ? 60.0 : 80.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Face
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          // Glasses
          if (hasGlasses)
            Positioned(
              top: size * 0.25,
              child: Container(
                width: size * 0.6,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          // Rainbow hair
          if (hasRainbowHair)
            Positioned(
              top: -size * 0.3,
              child: Container(
                width: size * 0.9,
                height: size * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          // Beard
          if (hasBeard)
            Positioned(
              bottom: size * 0.15,
              child: Container(
                width: size * 0.5,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          // Smile
          Positioned(
            bottom: size * 0.2,
            child: Container(
              width: size * 0.3,
              height: size * 0.1,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _WelcomeButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteColor,
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
