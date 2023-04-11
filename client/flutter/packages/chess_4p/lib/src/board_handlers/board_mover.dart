import 'package:chess_4p/src/domain/board.dart';
import 'package:chess_4p/src/board_handlers/board_analyzer.dart';

import '../domain/board_update.dart';
import '../domain/field.dart';
import '../domain/move.dart';
import '../domain/piece.dart';
import '../domain/piece_type.dart';

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

  /// Apply a [BoardUpdate] to the board.
  void applyBoardUpdate(BoardUpdate update) {
    for(final move in update.moves) {
      applyMove(move);
    }
    for(final player in update.eliminatedPlayers.keys) {
      board.setInactive(player);
    }
  }

  /// Reverse a [BoardUpdate] to the board.
  ///
  /// Should only be done,
  /// if this [BoardUpdate] was the last thing applied to the board.
  void reverseApplyBoardUpdate(BoardUpdate update) {
    for(final player in update.eliminatedPlayers.keys) {
      board.setActive(player);
    }
    for(var i = update.moves.length - 1; i >= 0; i--) {
      final move = update.moves[i];
      reverseApplyMove(move);
    }
  }

  /// Apply a [Move] to the board.
  void applyMove(Move move) {
    var fromPiece = board.getPiece(move.fromX, move.fromY);
    if(move.promotion != null) {
      fromPiece = Piece(direction: fromPiece.direction, type: move.promotion!);
    }
    fromPiece.hasBeenMoved = true;
    board.removePiece(move.fromX, move.fromY);
    board.overwritePiece(fromPiece, move.toX, move.toY);
  }

  /// Reverse a [Move] to the board.
  ///
  /// Should only be done,
  /// if this [Move] was the last thing applied to the board.
  void reverseApplyMove(Move move) {
    var fromPiece = board.getPiece(move.toX, move.toY);
    if(move.promotion != null) {
      fromPiece = Piece(direction: fromPiece.direction, type: PieceType.pawn);
    }
    fromPiece.hasBeenMoved = !move.firstMove;
    board.writePiece(fromPiece, move.fromX, move.fromY);
    if(move.hitPiece != null) {
      board.overwritePiece(move.hitPiece!, move.toX, move.toY);
    } else {
      board.removePiece(move.toX, move.toY);
    }
  }

  /// Shorthand for directly applying [analyseMoves].
  List<Move> analyzeAndApplyMoves(
    int fromX,
    int fromY,
    int toX,
    int toY, [
    PieceType? promotion,
  ]) {
    final moves = analyseMoves(fromX, fromY, toX, toY, promotion);
    for (final move in moves) {
      applyMove(move);
    }
    return moves;
  }

  /// Analyse a chess move into different [Move] objects.
  ///
  /// The only case where more than one [Move] is given back,
  /// is when a castle is analysed.
  List<Move> analyseMoves(
    int fromX,
    int fromY,
    int toX,
    int toY, [
    PieceType? promotion,
  ]) {
    final fromPiece = board.getPiece(fromX, fromY);
    final firstMove = !fromPiece.hasBeenMoved;
    Piece? hitPiece;
    if (!board.isEmpty(toX, toY)) {
      hitPiece = board.getPiece(toX, toY).copy();
    }
    final moves = [
      Move(
        fromX: fromX,
        fromY: fromY,
        toX: toX,
        toY: toY,
        firstMove: firstMove,
        movedPieceType: fromPiece.type,
        promotion: promotion,
        hitPiece: hitPiece,
      ),
    ];
    if (fromPiece.type == PieceType.king) {
      final rotationsFromUp = fromPiece.direction.clockwiseRotationsFromUp;
      final toXRotated = Field.clockwiseRotateXBy(toX, toY, -rotationsFromUp);
      final fromXRotated =
          Field.clockwiseRotateXBy(fromX, fromY, -rotationsFromUp);
      if ((toXRotated - fromXRotated).abs() == 2) {
        late final int rookFromX, rookFromY;
        late final int rookToX, rookToY;
        if (toXRotated == 5) {
          // left
          rookFromX = Field.clockwiseRotateXBy(3, 13, rotationsFromUp);
          rookFromY = Field.clockwiseRotateYBy(3, 13, rotationsFromUp);
          rookToX = Field.clockwiseRotateXBy(6, 13, rotationsFromUp);
          rookToY = Field.clockwiseRotateYBy(6, 13, rotationsFromUp);
        } else {
          // right
          rookFromX = Field.clockwiseRotateXBy(10, 13, rotationsFromUp);
          rookFromY = Field.clockwiseRotateYBy(10, 13, rotationsFromUp);
          rookToX = Field.clockwiseRotateXBy(8, 13, rotationsFromUp);
          rookToY = Field.clockwiseRotateYBy(8, 13, rotationsFromUp);
        }
        final rookMove = Move(
          fromX: rookFromX,
          fromY: rookFromY,
          toX: rookToX,
          toY: rookToY,
          movedPieceType: PieceType.rook,
          firstMove: true,
        );
        moves.add(rookMove);
      }
    }
    return moves;
  }

  /// Gives back true if a move is a pawn promotion.
  bool analyzeMoveIsPromotion(int fromX, int fromY, int toX, int toY) {
    final piece = board.getPiece(fromX, fromY);
    if (piece.type == PieceType.pawn) {
      final toYRotated = Field.clockwiseRotateYBy(
          toX, toY, -piece.direction.clockwiseRotationsFromUp);
      return toYRotated == 6;
    }
    return false;
  }
}
