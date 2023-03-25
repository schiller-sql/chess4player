import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_4p/src/accessible_positions_painter.dart';
import 'package:chess_4p/chess_4p.dart';

import 'chess_board_painter.dart';
import 'domain/piece_set.dart';

class ChessBoard extends StatefulWidget {
  final PieceSet pieceSet;
  final IChessGameRepository chessGameRepository;

  const ChessBoard({
    Key? key,
    required this.pieceSet,
    required this.chessGameRepository,
  }) : super(key: key);

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard>
    implements ChessGameRepositoryListener {
  IChessGameRepository get repo => widget.chessGameRepository;
  ReadableBoard get board => repo.board;
  BoardAnalyzer get boardAnalyzer => repo.boardAnalyzer;

  @override
  void initState() {
    super.initState();
    repo.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    repo.removeListener(this);
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
    final to = Field(toX, toY);
    if (selectableFields.contains(to) && repo.canMove) {
      setState(() {
        if (repo.moveIsPromotion(selectedField!, to)) {
          promotionCandidate = to;
        } else {
          repo.move(selectedField!, to);
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
      repo.move(selectedField!, promotionCandidate!, pieceType);
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
      child = widget.pieceSet.createPiece(
        piece.type,
        piece.isDead ? null : piece.direction,
      );
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
      painter: const ChessBoardPainter(
        backgroundTileColor2: Colors.black,
        backgroundTileColor1: Colors.white,
        backgroundColor: Colors.grey,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
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
            if (doingPromotion) _buildPromotionDialog(),
          ],
        ),
      ),
    );
  }

  @override
  void changed(IChessGameRepository chessGameRepository) {
    setState(() {
      if (selectedField != null) {
        if (boardAnalyzer.canAnalyze(selectedField!.x, selectedField!.y)) {
          selectableFields = boardAnalyzer.accessibleFields(
              selectedField!.x, selectedField!.y);
        } else {
          selectedField = null;
          selectableFields = {};
        }
      }
    });
  }

  @override
  void timerChange(String player, Duration duration, bool hasStarted) {
    // TODO: implement timerChange
  }
}
