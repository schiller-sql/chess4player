import 'package:flutter/material.dart';

class ChessBoardPainter extends CustomPainter {
  static final blackPaint = Paint()..color = Colors.black;
  static final whitePaint = Paint()..color = Colors.white;
  static final backgroundPaint = Paint()..color = Colors.grey;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    final chessUnit = size.width / 14;
    final chessSquareUnit = Size(chessUnit, chessUnit);
    var isBlack = true;
    for(var ix = 0; ix < 14; ix++) {
      y: for(var iy = 0; iy < 14; iy++) {
        isBlack = !isBlack;
        if((ix < 3 || ix > 10) && (iy < 3 || iy > 10)) {
          continue y;
        }
        final off = Offset(ix * chessUnit, iy * chessUnit);
        final rect = off & chessSquareUnit;
        var paint = isBlack ? blackPaint : whitePaint;
        canvas.drawRect(rect, paint);
      }
      isBlack = !isBlack;
    }
  }

  @override
  bool shouldRepaint(covariant ChessBoardPainter oldDelegate) {
    return false;
  }
}