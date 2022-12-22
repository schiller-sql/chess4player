import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/src/accessible_positions_painter.dart';
import 'package:chess_4p/chess_4p.dart';

import 'chess_board_painter.dart';
import 'domain/piece_set.dart';

class ChessBoard extends StatefulWidget {
  final PieceSet pieceSet;

  const ChessBoard({Key? key, required this.pieceSet}) : super(key: key);

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  late Board board;
  late BoardAnalyzer boardAnalyzer;
  late BoardMover boardMover;

  @override
  void initState() {
    super.initState();
    board = Board.standard();
    board.removePiece(6, 12);
    board.removePiece(1, 7);
    board.removePiece(8, 13);
    board.removePiece(9, 13);
    boardAnalyzer =
        BoardAnalyzer(board: board, analyzingDirection: Direction.up);
    boardMover = BoardMover(board: board);
  }

  Set<Field> selectableFields = {};

  Field? selectedField;

  void tapField(Field field) {
    setState(() {
      if (field == selectedField) {
        selectedField = null;
      } else {
        selectedField = field;
      }
      if (selectedField == null ||
          !boardAnalyzer.canAnalyze(selectedField!.x, selectedField!.y)) {
        selectableFields = {};
      } else {
        selectableFields =
            boardAnalyzer.accessibleFields(selectedField!.x, selectedField!.y);
      }
    });
  }

  Widget chessFieldItemBuilder(int x, int y) {
    Widget? child;
    if (!board.isEmpty(x, y)) {
      final piece = board.getPiece(x, y);
      child = widget.pieceSet.createPiece(piece.type, piece.direction);
    }
    if (selectedField?.x == x && selectedField?.y == y) {
      child = Opacity(
        opacity: 0.6,
        child: ColoredBox(
          color: Colors.green,
          child: child,
        ),
      );
    }
    if (boardAnalyzer.canAnalyze(x, y)) {
      child = GestureDetector(
        onTapDown: (_) {
          final field = Field(x, y);
          tapField(field);
        },
        onTap: () {},
        child: child,
      );
    } else {
      child = GestureDetector(
        onTap: () {
          final field = Field(x, y);
          if(selectableFields.contains(field)) {
            setState((){
              boardMover.nonPromotionMove(selectedField!.x, selectedField!.y, x, y);
              selectedField = null;
              selectableFields = {};
            });
          }
        },
        child: child,
      );
    }
    return child;
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
          itemBuilder: (context, i) => chessFieldItemBuilder(i % 14, i ~/ 14),
        ),
      ),
    );
  }
}
