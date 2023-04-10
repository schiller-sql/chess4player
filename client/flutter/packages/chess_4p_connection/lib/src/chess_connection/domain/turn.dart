import 'lose_reason.dart';
import 'raw_move.dart';

class Turn {
  final Map<String, LoseReason> lostPlayers;
  final RawMove? move;
  final Duration remainingTime;

  Turn({
    required this.lostPlayers,
    required this.move,
    required this.remainingTime,
  });

  factory Turn.fromJson(Map<String, dynamic> json) {
    final lostPlayersJson = json["lost-participants"] as Map;
    final lostPlayers = lostPlayersJson.map<String, LoseReason>(
      (player, rawLoseReason) => MapEntry(
        player,
        LoseReason.fromJson(rawLoseReason),
      ),
    );
    final jsonMove = json["move"] as Map<String, dynamic>?;
    final RawMove? move;
    if (jsonMove != null) {
      move = RawMove.fromJson(jsonMove);
    } else {
      move = null;
    }
    final remainingTimeMilliseconds = json["remaining-time"];
    final remainingTime = Duration(milliseconds: remainingTimeMilliseconds);
    return Turn(
      remainingTime: remainingTime,
      lostPlayers: lostPlayers,
      move: move,
    );
  }
}
