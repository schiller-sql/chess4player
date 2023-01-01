import 'domain/room.dart';
import 'domain/room_update.dart';

/// A repository to connect into chess rooms
abstract class IChessRoomRepository {
  /// If the request has been sent to join or create a room.
  bool get isJoiningRoom;

  /// Room updates in a broadcast stream
  Stream<RoomUpdate> get roomUpdateStream;

  /// How many participants are in the current room in a broadcast stream,
  /// should only be listened to if the [currentRoom]
  /// or the last update from the [roomUpdateStream],
  /// contain that the client is the admin of a room
  Stream<int> get chessRoomParticipantsCount;

  void resetCurrentRoom();

  /// The last update of [chessRoomParticipantsCount]
  int get currentRoomParticipantsCount;

  /// In which room the client currently is in
  ///
  /// (since begin of the chess repository listening,
  /// if the client was in a room before,
  /// the repository does not know )
  ChessRoom? get currentRoom;

  /// Join a room, only possible if the client is not in a room
  void joinRoom({required String code, String? playerName});

  /// Create a room and join it (=> be the admin of the room),
  /// only possible if the client is not in a room
  void createRoom({String? playerName});

  /// Leave the room which one is currently in,
  /// only possible if the client is in a room
  void leaveRoom();
}
