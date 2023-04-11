import 'package:chess_4p/chess_4p.dart';

class Game {
  final Duration time;
  final List<String?> playerOrder;
  final int ownPlayerPosition;

  Game({
    required this.time,
    required this.playerOrder,
    required this.ownPlayerPosition,
  });

  Direction getDirectionFromPlayerName(String playerName) {
    final playerIndex = playerOrder.indexWhere(
      (playerNameInOrder) => playerName == playerNameInOrder,
    );
    return Direction.fromInt(playerIndex - ownPlayerPosition);
  }

}
