import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/utils/assets.dart';

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
                const Color(0xFFFF4A1C), // Đỏ cam đậm ở trên (giống Figma)
                primaryColor, // Cam đậm ở dưới
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
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
                          child: Image.asset(
                            FoodieAssets.logo,
                            width: 55,
                            height: 55,
                            fit: BoxFit.contain,
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
                      const Spacer(flex: 2),
                      // Nút "Get started" - nền trắng, chữ cam
                      _WelcomeButton(
                        text: FoodieStrings.getStarted,
                        onPressed: () => Navigator.pushNamed(context, authRoute),
                      ),
                    ],
                  ),
                ),
                // Nhân vật 3D ở phần dưới (đặt sau để nằm trên cùng)
                Positioned(
                  bottom: 140,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Nhân vật 2 - phải (bị che một phần phía sau)
                        Positioned(
                          left: 20,
                          bottom: 0,
                          child: Image.asset(
                            FoodieAssets.toyFace49,
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading toyFace49: $error');
                              debugPrint('Path: ${FoodieAssets.toyFace49}');
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.red.withValues(alpha: 0.3),
                                child: const Icon(Icons.error, color: Colors.white),
                              );
                            },
                          ),
                        ),
                        // Nhân vật 1 - nổi bật nhất bên trái (phía trước)
                        Positioned(
                          right: 20,
                          bottom: 0,
                          child: Image.asset(
                            FoodieAssets.toyFace29,
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading toyFace29: $error');
                              debugPrint('Path: ${FoodieAssets.toyFace29}');
                              return Container(
                                width: 150,
                                height: 150,
                                color: Colors.red.withValues(alpha: 0.3),
                                child: const Icon(Icons.error, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
