import 'package:chess_4p/src/pieces/piece_type.dart';

import '../direction.dart';

/// Represents a chess piece on the board.
/// The [direction] is which direction a piece is facing
/// and the
///
/// The playing player will always have the pieces with the [direction]
/// [Direction.up]
class Piece {
  final Direction direction;
  final PieceType type;

  Piece({required this.direction, required this.type});
}