import 'package:chess_4p/src/domain/piece_type.dart';

import 'direction.dart';

/// Represents a chess piece on the board, for four players.
class Piece {
  /// which direction this piece faces and to which player it therefore belong
  final Direction direction;

  /// Which of the chess pieces this piece is
  final PieceType type;

  /// The [hasBeenMoved] is important for king, pawns and the rook.
  bool hasBeenMoved = false;

  /// If the player of this piece has been checkmated or remi
  /// and this piece is no longer active (can be ignored for checking).
  bool isDead = false;

  Piece({required this.direction, required this.type});

  Piece._({
    required this.direction,
    required this.type,
    required this.hasBeenMoved,
    required this.isDead,
  });

  Piece copy() {
    return Piece._(
      direction: direction,
      type: type,
      hasBeenMoved: hasBeenMoved,
      isDead: isDead,
    );
  }
}
