import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/src/accessible_positions_painter.dart';
import 'package:chess_4p/chess_4p.dart';

import 'chess_board_painter.dart';

class ChessBoard extends StatelessWidget {
  List<Field> selectableFields = [Field(8, 8)];
  Field? get selectedField => Field(8,8);

  Widget chessFieldItemBuilder(int x, int y) {
    if(selectedField?.x == x && selectedField?.y == y) {
      return const Opacity(opacity: 0.6, child: ColoredBox(color: Colors.green,),);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: AccessiblePositionsPainter(selectableFields),
      painter: ChessBoardPainter(),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          itemCount: 14 * 14,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 14),
          itemBuilder: (context, i) =>
              chessFieldItemBuilder(i % 14, i ~/ 14),
        ),
      ),
    );
  }
}
