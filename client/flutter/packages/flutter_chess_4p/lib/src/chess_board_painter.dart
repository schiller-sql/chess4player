import 'package:flutter/material.dart';

class ChessBoardPainter extends CustomPainter {

  final Color backgroundColor, backgroundTileColor1, backgroundTileColor2;

  const ChessBoardPainter({
    required this.backgroundColor,
    required this.backgroundTileColor1,
    required this.backgroundTileColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    final tile1Paint = Paint()..color = backgroundTileColor1;
    final tile2Paint = Paint()..color = backgroundTileColor2;

    canvas.drawRect(Offset.zero & size, backgroundPaint);
    final chessUnit = size.width / 14;
    final chessSquareUnit = Size(chessUnit, chessUnit);
    var isBlack = true;
    for (var ix = 0; ix < 14; ix++) {
      y:
      for (var iy = 0; iy < 14; iy++) {
        isBlack = !isBlack;
        if ((ix < 3 || ix > 10) && (iy < 3 || iy > 10)) {
          continue y;
        }
        final off = Offset(ix * chessUnit, iy * chessUnit);
        final rect = off & chessSquareUnit;
        var paint = isBlack ? tile1Paint : tile2Paint;
        canvas.drawRect(rect, paint);
      }
      isBlack = !isBlack;
    }
  }

  @override
  bool shouldRepaint(covariant ChessBoardPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.backgroundTileColor1 != backgroundTileColor1 ||
        oldDelegate.backgroundTileColor2 != backgroundTileColor2;
  }
}
