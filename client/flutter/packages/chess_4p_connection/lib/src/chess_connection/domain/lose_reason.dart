enum LoseReason {
  resign,
  remi,
  checkmate,
  time;

  String getText({String? player, bool withPlayer = true}) {
    String playerRep;
    if (withPlayer) {
      if (player == null) {
        playerRep = "You have ";
      } else {
        playerRep = "$player has ";
      }
    } else {
      playerRep = "";
    }
    switch (this) {
      case resign:
        return "$playerRep resigned";
      case remi:
        return "$playerRep been set remi";
      case checkmate:
        return "$playerRep been set checkmate";
      case time:
        return "$playerRep run out of time";
    }
  }

  String getTextWithoutNameComplex({
    required bool causing,
    required bool isSelf,
  }) {
    if (causing) {
      switch (this) {
        case remi:
          return " to be set remi";
        case checkmate:
          return " to be set checkmate";
        case time:
          throw UnimplementedError("Does not make any sense");
        case resign:
          throw UnimplementedError("Does not make any sense");
      }
    }
    return getText(player: isSelf ? null : "", withPlayer: false);
  }

  static LoseReason fromJson(String rawLoseReason) {
    switch (rawLoseReason) {
      case "resign":
        return resign;
      case "remi":
        return remi;
      case "checkmate":
        return checkmate;
      case "time":
        return time;
    }
    throw ArgumentError("Not a valid lose reason");
  }
}
