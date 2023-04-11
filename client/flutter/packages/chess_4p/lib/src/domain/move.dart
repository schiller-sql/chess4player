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

  final PieceType movedPieceType;

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
    required this.movedPieceType,
    this.promotion,
    this.hitPiece,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          runtimeType == other.runtimeType &&
          fromX == other.fromX &&
          fromY == other.fromY &&
          toX == other.toX &&
          toY == other.toY &&
          firstMove == other.firstMove &&
          promotion == other.promotion &&
          hitPiece == other.hitPiece;

  @override
  int get hashCode =>
      fromX.hashCode ^
      fromY.hashCode ^
      toX.hashCode ^
      toY.hashCode ^
      firstMove.hashCode ^
      promotion.hashCode ^
      hitPiece.hashCode;
}
