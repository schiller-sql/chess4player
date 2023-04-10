enum LoseReason {
  resign,
  remi,
  checkmate,
  time;

  String getText(String? player) {
    if (player == null) {
      switch (this) {
        case resign:
          return "You have resigned";
        case remi:
          return "You have been set remi";
        case checkmate:
          return "You have been set checkmate";
        case time:
          return "You have run out of time";
      }
    } else {
      switch (this) {
        case resign:
          return "$player has resigned";
        case remi:
          return "$player has been set remi";
        case checkmate:
          return "$player has been checkmated";
        case time:
          return "$player has run out of time";
      }
    }
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
