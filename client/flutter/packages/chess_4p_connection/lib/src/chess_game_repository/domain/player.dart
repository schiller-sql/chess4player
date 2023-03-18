class Player {
  String name;
  String? lostReason;
  Duration remainingTime;

  Player({
    required this.name,
    required this.remainingTime,
  });

  bool get hasLost => lostReason != null;
}
