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

  void tapOwnPiece(Field field) {
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

  void movePiece(int toX, int toY) {
    final field = Field(toX, toY);
    if (selectableFields.contains(field)) {
      setState(() {
        final fromX = selectedField!.x, fromY = selectedField!.y;
        if (boardMover.moveIsPromotion(fromX, fromY, toX, toY)) {
          promotionCandidate = field;
        } else {
          boardMover.nonPromotionMove(fromX, fromY, toX, toY);
          selectedField = null;
        }
        selectableFields = {};
      });
    }
  }

  void cancelPromotion() {
    setState(() {
      selectedField = null;
      promotionCandidate = null;
    });
  }

  void executePromotion(PieceType pieceType) {
    setState(() {
      boardMover.promotion(
        selectedField!.x,
        selectedField!.y,
        promotionCandidate!.x,
        promotionCandidate!.y,
        pieceType,
      );
      promotionCandidate = null;
      selectedField = null;
    });
  }

  Field? promotionCandidate;

  bool get doingPromotion => promotionCandidate != null;

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
          tapOwnPiece(field);
        },
        onTap: () {},
        child: child,
      );
    } else {
      child = GestureDetector(
        onTap: () {
          movePiece(x, y);
        },
        child: child,
      );
    }
    return child;
  }

  Widget _buildPromotionDialogSection({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
            const ContinuousRectangleBorder(),
          ),
          overlayColor: MaterialStateProperty.all(
            Colors.transparent,
          ),
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.yellow;
              }
              if (states.contains(MaterialState.focused) ||
                  states.contains(MaterialState.hovered)) {
                return Colors.green;
              }
              return null;
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: child,
      ),
    );
  }

  Widget _buildPromotionDialog() {
    Field f = promotionCandidate!;
    return SizedBox.expand(
      child: GestureDetector(
        onTap: cancelPromotion,
        child: ColoredBox(
          color: Colors.black.withAlpha(100), // TODO: not over chess pieces...
          child: Align(
            alignment: FractionalOffset(f.x / 13, (f.y - 4) / (14 - 5)),
            child: FractionallySizedBox(
              widthFactor: 1 / 14,
              heightFactor: 5 / 14,
              child: ColoredBox(
                color: Colors.blueAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPromotionDialogSection(
                      child: const Icon(
                        Icons.close,
                        size: 32,
                      ),
                      onPressed: cancelPromotion,
                    ),
                    for (final pieceType in const [
                      PieceType.knight,
                      PieceType.bishop,
                      PieceType.rook,
                      PieceType.queen
                    ])
                      _buildPromotionDialogSection(
                        child: SizedBox.expand(
                          child: widget.pieceSet.createPiece(
                            pieceType,
                            Direction.up,
                          ),
                        ),
                        onPressed: () => executePromotion(pieceType),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: AccessiblePositionsPainter(selectableFields),
      painter: ChessBoardPainter(),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            if (doingPromotion) _buildPromotionDialog(),
            IgnorePointer(
              ignoring: doingPromotion,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 14 * 14,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 14),
                itemBuilder: (context, i) =>
                    chessFieldItemBuilder(i % 14, i ~/ 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
