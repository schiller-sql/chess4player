class Player {
  String name;
  String? lostReason;
  Duration remainingTime;
  bool isOnTurn = false;

  bool get isOut => lostReason != null;

  Player({
    required this.name,
    required this.remainingTime,
  });

  bool get hasLost => lostReason != null;
}
