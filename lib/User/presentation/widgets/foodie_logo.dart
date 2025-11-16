import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

/// Widget hiển thị logo Foodie (chef hat + lips)
/// Nếu không có file ảnh, hiển thị logo bằng code
class FoodieLogo extends StatelessWidget {
  const FoodieLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Chef hat (orange outline)
        CustomPaint(
          size: const Size(80, 60),
          painter: _ChefHatPainter(),
        ),
        const SizedBox(height: 8),
        // Lips (red)
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFFF0000),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _ChefHatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Vẽ phần trên của chef hat (wavy)
    final path = Path();
    path.moveTo(10, size.height * 0.3);
    
    // Vẽ đường sóng
    path.quadraticBezierTo(15, 15, 25, 20);
    path.quadraticBezierTo(35, 25, 45, 20);
    path.quadraticBezierTo(55, 15, 70, 20);
    
    canvas.drawPath(path, paint);

    // Vẽ band
    final bandPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(10, size.height * 0.7),
      Offset(size.width - 10, size.height * 0.7),
      bandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


