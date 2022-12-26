import 'domain/room.dart';
import 'domain/room_update.dart';

abstract class IChessRoomRepository {
  Stream<RoomUpdate> get roomUpdateStream;

  Stream<int> get chessRoomParticipantsCount;

  int get currentRoomParticipantsCount;

  ChessRoom? get currentRoom;

  void joinRoom({required String code, String? playerName});

  void createRoom({String? playerName});

  void leaveRoom();
}