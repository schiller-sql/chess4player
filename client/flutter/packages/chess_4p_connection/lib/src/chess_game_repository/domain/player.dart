import 'package:chess_4p/chess_4p.dart';

import '../../chess_connection/domain/lose_reason.dart';

class Player {
  final String name;
  LoseReason? lostReason;
  Duration remainingTime;
  bool isOnTurn = false;
  final Direction colorDirection;
  final Direction directionFromOwn;

  bool get isOut => lostReason != null;

  Player({
    required this.name,
    required this.remainingTime,
    required this.colorDirection,
    required this.directionFromOwn,
  });

  bool get hasLost => lostReason != null;
}
