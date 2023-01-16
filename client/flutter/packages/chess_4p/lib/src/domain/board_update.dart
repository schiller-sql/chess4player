import 'direction.dart';
import 'move.dart';

/// A update on the board, for example a move is made,
/// and two players go checkmate because of it.
class BoardUpdate {
  /// The list of moves that have been made in this board update.
  final List<Move> moves;

  /// The players which have been eliminated.
  final Set<Direction> eliminatedPlayers;

  BoardUpdate({
    required this.moves,
    required this.eliminatedPlayers,
  });
}
