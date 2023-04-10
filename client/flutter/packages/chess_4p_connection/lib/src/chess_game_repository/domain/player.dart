import '../../chess_connection/domain/lose_reason.dart';

class Player {
  String name;
  LoseReason? lostReason;
  Duration remainingTime;
  bool isOnTurn = false;

  bool get isOut => lostReason != null;

  Player({
    required this.name,
    required this.remainingTime,
  });

  bool get hasLost => lostReason != null;
}
