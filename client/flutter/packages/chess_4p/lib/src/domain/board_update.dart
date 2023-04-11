import 'direction.dart';
import 'move.dart';

/// A update on the board, for example a move is made,
/// and two players go checkmate because of it.
class BoardUpdate<EliminationType> {
  /// The list of moves that have been made in this board update.
  final List<Move> moves;

  /// The player responsible for the move (optional)
  final Direction? playerDirection;

  /// The players which have been eliminated.
  final Map<Direction, EliminationType> eliminatedPlayers;

  BoardUpdate({
    this.playerDirection,
    this.moves = const [],
    this.eliminatedPlayers = const {},
  });
}
