/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:mathebuddy/style.dart';

class EventPainter extends CustomPainter {
  double strokeWidth;
  bool middleLine;
  double percentage;

  EventPainter(this.strokeWidth, this.middleLine, this.percentage);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    Paint paint = Paint();

    var width = size.width;

    Color color =
        percentage >= 0.5 ? Style().matheBuddyGreen : Style().matheBuddyRed;

    paint.color = const Color.fromARGB(255, 66, 66, 66);
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 25), Offset(width, 25), paint);

    paint.color = color;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 25), Offset(percentage * width, 25), paint);

    if (middleLine) {
      paint.color = Colors.white;
      paint.strokeWidth = 4.0;
      paint.strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(width / 2, 10), Offset(width / 2, 40), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
