import 'piece.dart';
import 'piece_type.dart';

/// A move by a piece, that is reversible.
///
/// A castle is represented by two [Move] objects,
/// one for the king and one for the rook.
class Move {
  /// The coordinates from which the piece moves
  final int fromX, fromY;

  /// The coordinates to which the piece moves
  final int toX, toY;

  /// If the piece moved was moved for the first time
  final bool firstMove;

  /// If the piece got a promotion.
  ///
  /// If this is true, then the piece was a pawn.
  final PieceType? promotion;

  /// A copy of the [Piece] that may have been hit
  final Piece? hitPiece;

  Move({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.firstMove,
    this.promotion,
    this.hitPiece,
  });
}
