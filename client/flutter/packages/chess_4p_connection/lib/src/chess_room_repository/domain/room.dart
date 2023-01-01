/// A chess room
class ChessRoom {
  /// The code with which the chess room can be joined
  final String code;

  /// The name of the client in the room
  final String playerName;

  /// If the client is the creator and admin of the chess room
  final bool isAdmin;

  const ChessRoom({
    required this.code,
    required this.playerName,
    required this.isAdmin,
  });

  @override
  String toString() {
    return 'ChessRoom{code: $code, playerName: $playerName, isAdmin: $isAdmin}';
  }
}
