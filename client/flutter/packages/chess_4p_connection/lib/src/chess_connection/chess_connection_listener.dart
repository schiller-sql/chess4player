import 'chess_connection.dart';
import 'domain/turn.dart';

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
    List<Turn> turns,
  ) {}

  /// See protocol: type: game, subtype: player-resigned
  void playerResign(String playerName) {}

  /// See protocol: type: game, subtype: draw-request
  void drawRequest(String requesterName) {}
}
