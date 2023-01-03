import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/src/chess_board_painter.dart';

class EmptyChessBoard extends StatelessWidget {
  final Color color1, color2;
  final Widget? child;

  const EmptyChessBoard({
    super.key,
    this.color1 = Colors.white,
    this.color2 = Colors.black,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: ChessBoardPainter(
          backgroundColor: Colors.transparent,
          backgroundTileColor1: color1,
          backgroundTileColor2: color2,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: child,
        ),
      ),
    );
  }
}
