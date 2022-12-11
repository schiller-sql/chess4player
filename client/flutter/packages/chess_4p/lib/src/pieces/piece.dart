import 'package:chess_4p/src/pieces/piece_type.dart';

import '../direction.dart';

/// Represents a chess piece on the board.
/// The [direction] is which direction a piece is facing
/// and the
///
/// The playing player will always have the pieces with the [direction]
/// [Direction.up]
class Piece {
  /// which direction this piece faces and to which player it therefore belong
  final Direction direction;

  /// Which of the chess pieces this piece is
  final PieceType type;

  /// The [hasBeenMoved] is important for king, pawns and the rook
  bool hasBeenMoved = false;

  Piece({required this.direction, required this.type});
}
