/// mathe:buddy - a gamified app for higher math
/// https://mathebuddy.github.io/
/// (c) 2022-2024 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:mathebuddy/style.dart';

class EventPainter extends CustomPainter {
  double width;
  double percentage = 1.0;

  EventPainter(this.width);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    Color color =
        percentage >= 0.5 ? Style().matheBuddyGreen : Style().matheBuddyRed;

    paint.color = const Color.fromARGB(255, 66, 66, 66);
    paint.strokeWidth = 20;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(10, 25), Offset(width, 25), paint);

    paint.color = color;
    paint.strokeWidth = 20;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(10, 25), Offset(percentage * width, 25), paint);

    paint.color = Colors.black;
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(width / 2, 10), Offset(width / 2, 40), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
