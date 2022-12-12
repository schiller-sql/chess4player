import 'package:chess_4p/src/board/board.dart';
import 'package:chess_4p/src/board_analyzer.dart';

import 'field.dart';
import 'pieces/piece.dart';
import 'pieces/piece_type.dart';

/// Moves pieces around on a given [Board].
///
/// Note that this class does not check if the inputs are correct moves,
/// it just executes the moves and changes all [Piece]s and their position,
/// to make this move valid. This also results in all [Piece.hasBeenMoved]
/// to be set to true.
///
/// To check for valid moves, use the [BoardAnalyzer] instead.
///
/// A move where the king is moved two to the right or left,
/// is interpreted as a castle.
///
/// A move where the pawn is moved over the middle,
/// is interpreted as a promotion.
class BoardMover {
  /// The [Board] on which the pieces should be moved.
  final Board board;

  /// Standard constructor to give the [board] on which to move.
  BoardMover({required this.board});

  /// If a move is a pawn promotion.
  bool moveIsPromotion(int fromX, int fromY, int toX, int toY) {
    final piece = board.getPiece(fromX, fromY);
    if (piece.type == PieceType.pawn) {
      final toYRotated = Field.clockwiseRotateYBy(
          toX, toY, -piece.direction.clockwiseRotationsFromUp);
      return toYRotated == 6;
    }
    return false;
  }

  /// Perform a non promotion move.
  ///
  /// It is asserted that this move is not a promotion.
  void nonPromotionMove(int fromX, int fromY, int toX, toY) {
    assert(!moveIsPromotion(fromX, fromY, toX, toY));

    final piece = board.getPiece(fromX, fromY);
    piece.hasBeenMoved = true;
    board.move(fromX, fromY, toX, toY);
    if (piece.type == PieceType.king) {
      final toXRotated = Field.clockwiseRotateXBy(
          toX, toY, -piece.direction.clockwiseRotationsFromUp);
      if (toXRotated == 5) {
        // left
        final rookFromX = Field.clockwiseRotateXBy(
            3, 13, piece.direction.clockwiseRotationsFromUp);
        final rookFromY = Field.clockwiseRotateYBy(
            3, 13, piece.direction.clockwiseRotationsFromUp);
        final rookToX = Field.clockwiseRotateXBy(
            6, 13, piece.direction.clockwiseRotationsFromUp);
        final rookToY = Field.clockwiseRotateYBy(
            6, 13, piece.direction.clockwiseRotationsFromUp);
        board.move(rookFromX, rookFromY, rookToX, rookToY);
      } else if (toXRotated == 9) {
        // right
        final rookFromX = Field.clockwiseRotateXBy(
            10, 13, piece.direction.clockwiseRotationsFromUp);
        final rookFromY = Field.clockwiseRotateYBy(
            10, 13, piece.direction.clockwiseRotationsFromUp);
        final rookToX = Field.clockwiseRotateXBy(
            8, 13, piece.direction.clockwiseRotationsFromUp);
        final rookToY = Field.clockwiseRotateYBy(
            8, 13, piece.direction.clockwiseRotationsFromUp);
        board.move(rookFromX, rookFromY, rookToX, rookToY);
      }
    }
  }

  /// Perform a promotion move, promote to the [change].
  ///
  /// It is asserted that this move is a promotion
  /// and that [change] is a valid promotion [PieceType] (not a king/pawn).
  void promotion(
    int fromX,
    int fromY,
    int toX,
    int toY,
    PieceType change,
  ) {
    assert(change != PieceType.king);
    assert(change != PieceType.pawn);

    final piece = board.getPiece(fromX, fromY);
    piece.hasBeenMoved = true;

    board.move(fromX, fromY, toX, toY);
    assert(piece.type == PieceType.pawn);

    final toYRotated = Field.clockwiseRotateYBy(
        toX, toY, -piece.direction.clockwiseRotationsFromUp);
    assert(toYRotated == 6);

    board.overwritePiece(
        Piece(direction: piece.direction, type: change), toX, toY);
  }
}
