import 'package:blogmanname/constants/colors.dart';
import 'package:flutter/material.dart';

class AuthClipPath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = KColors.teal
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0399999618530273;

    Path path0 = Path();
    path0.moveTo(size.width, size.height);
    path0.lineTo(0, size.height);
    path0.lineTo(0, size.height * 0.6960000);
    path0.quadraticBezierTo(size.width * 0.2500000, size.height * 0.5480000,
        size.width * 0.5000000, size.height * 0.5440000);
    path0.quadraticBezierTo(size.width * 0.7500000, size.height * 0.5420000,
        size.width, size.height * 0.6980000);

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
