/// mathe:buddy - a gamified app for higher math
/// (c) 2022-2023 by TH Koeln
/// Author: Andreas Schwenk contact@compiler-construction.com
/// Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
/// License: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// An visual edge in the level overview graph.
class UnitEdge {
  double x1 = 0;
  double y1 = 0;
  double x2 = 0;
  double y2 = 0;
  UnitEdge(this.x1, this.x2, this.y1, this.y2);
}

// Visual edges in the level overview graph.
class UnitEdges extends CustomPainter {
  List<UnitEdge> _edges = [];
  double strokeWidth = 10.0;

  UnitEdges(this.strokeWidth);

  void addEdge(double x1, double y1, double x2, double y2) {
    _edges.add(UnitEdge(x1, x2, y1, y2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.black87;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    for (var e in _edges) {
      Offset startingOffset = Offset(e.x1, e.y1);
      Offset endingOffset = Offset(e.x2, e.y2);
      canvas.drawLine(startingOffset, endingOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
