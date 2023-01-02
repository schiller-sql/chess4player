/// A reason to fail joining a chess room
enum RoomJoinErrorReason {
  /// The game is already full
  full("full", "The room is already full."),

  /// The game has already started
  started("started", "The admin of the room has already started a game."),

  /// The code is invalid
  notFound("not found", "A room with the given code was not found.");

  final String _stringRep;

  final String message;

  const RoomJoinErrorReason(this._stringRep, this.message);

  static RoomJoinErrorReason fromString(String s) {
    for (final reason in values) {
      if (reason._stringRep == s) return reason;
    }
    throw ArgumentError("$s is not a valid RoomJoinErrorReason");
  }

  @override
  String toString() {
    return _stringRep;
  }
}
