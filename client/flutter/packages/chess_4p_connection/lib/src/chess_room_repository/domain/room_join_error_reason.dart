/// A reason to fail joining a chess room
enum RoomJoinErrorReason {
  /// The game is already full
  full("full"),

  /// The game has already started
  started("started"),

  /// The code is invalid
  notFound("not found");

  final String _stringRep;

  const RoomJoinErrorReason(this._stringRep);

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
