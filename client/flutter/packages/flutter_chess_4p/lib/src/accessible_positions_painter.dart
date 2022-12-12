import 'package:chess_4p/chess_4p.dart';
import 'package:flutter/material.dart';

class AccessiblePositionsPainter extends CustomPainter {
  static final Paint accessiblePositionPaint = Paint()
    ..color = Colors.grey[600]!.withAlpha(200);
  final Set<Field> accessiblePositions;

  AccessiblePositionsPainter(this.accessiblePositions);

  @override
  void paint(Canvas canvas, Size size) {
    if (accessiblePositions.isEmpty) return;

    final chessUnit = size.width / 14;
    final halfChessUnit = chessUnit / 2;
    for (var ix = 0; ix < 14; ix++) {
      y:
      for (var iy = 0; iy < 14; iy++) {
        if ((ix < 3 || ix > 10) && (iy < 3 || iy > 10)) {
          continue y;
        }
        final isAccessible =
            accessiblePositions.any((field) => field.x == ix && field.y == iy);
        if (!isAccessible) {
          continue y;
        }
        final off = Offset(
          ix * chessUnit + halfChessUnit,
          iy * chessUnit + halfChessUnit,
        );
        canvas.drawCircle(off, chessUnit / 8, accessiblePositionPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AccessiblePositionsPainter oldDelegate) =>
      oldDelegate.accessiblePositions != accessiblePositions;
}
