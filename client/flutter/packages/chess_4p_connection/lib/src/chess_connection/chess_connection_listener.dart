import 'chess_connection.dart';
import 'domain/raw_move.dart';

/// Listen to a [ChessConnection]
abstract class ChessConnectionListener {
  /// See protocol: type: room, subtype: created
  void createdRoom(String code, String name) {}

  /// See protocol: type: room, subtype: joined
  void joinedRoom(String name) {}

  /// If was forced true:
  ///   See protocol: type: room, subtype: disbanded
  /// if was forced false:
  ///   See protocol: type: room, subtype: left
  void leftRoom(bool wasForced) {}

  /// See protocol: type: room, subtype: participants-count-update
  void participantsCountUpdate(int count) {}

  /// See protocol: type: room, subtype: join-failed
  void joinError(String error) {}

  /// See protocol: type: game, subtype: started
  void gameStarted(Duration time, List<String?> playerOrder) {}

  /// See protocol: type: game, subtype: game-update
  void gameUpdate(
    String? gameEnd,
    Map<String, String> lostPlayers,
    List<RawMove> moves,
    Duration remainingTime,
  ) {}

  /// See protocol: type: game, subtype: player-resigned
  void playerResign(String playerName) {}
}
