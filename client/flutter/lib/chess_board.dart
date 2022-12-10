import 'package:flutter/material.dart';

import 'chess_board_painter.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChessBoardPainter(),
      child: const AspectRatio(aspectRatio: 1),
    );
  }
}
