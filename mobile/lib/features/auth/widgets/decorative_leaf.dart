import 'package:flutter/material.dart';

class DecorativeLeaf extends StatelessWidget {
  final bool isLeft;

  const DecorativeLeaf({super.key, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: isLeft ? 1 : -1,
      child: Opacity(
        opacity: 0.85,
        child: SizedBox(
          width: 55,
          height: 70,
          child: CustomPaint(
            painter: _LeafPainter(),
          ),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBE3C8).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // First large leaf
    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.15,
    );
    path1.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.6,
      0,
      size.height * 0.4,
    );
    path1.close();
    canvas.drawPath(path1, paint);

    // Second small leaf
    final paint2 = Paint()
      ..color = const Color(0xFFDCECDC).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.85,
      0,
      size.height * 0.6,
    );
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
