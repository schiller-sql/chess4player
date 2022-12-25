import 'dart:async';

import 'chess_connection.dart';
import 'chess_connection_listener.dart';

class ChessRoom {
  final String code;
  final String playerName;
  final bool isAdmin;

  ChessRoom(this.code, this.playerName, this.isAdmin);
}

abstract class IChessRoomRepository {
  Stream<ChessRoom?> get roomStream;

  Stream<int> get chessRoomParticipantsCount;

  int get currentRoomParticipantsCount;

  ChessRoom? get currentRoom;

  void joinRoom({required String code, String? playerName});

  void createRoom({String? playerName});

  void leaveRoom();
}

class ChessRoomRepository
    implements IChessRoomRepository, ChessConnectionListener {
  bool _isJoining = false;

  final ChessConnection connection;

  ChessRoomRepository(this.connection);

  @override
  void createdRoom(String code, String name) {
    _participantsCountChange(1);
  }

  @override
  void joinError(String error) {}

  @override
  void joinedRoom(String name) {
  }

  @override
  void leftRoom(bool wasForced) {}

  @override
  void participantsCountUpdate(int count) {}

  void _roomChange(ChessRoom? newRoom) {
    _roomSC.add(newRoom);
    currentRoom = newRoom;
  }

  void _participantsCountChange(int newCount) {
    _chessRoomParticipantsCountSC.add(newCount);
    currentRoomParticipantsCount = newCount;
  }

  final StreamController<ChessRoom?> _roomSC = StreamController.broadcast();

  @override
  Stream<ChessRoom?> get roomStream => _roomSC.stream;

  final StreamController<int> _chessRoomParticipantsCountSC =
      StreamController.broadcast();

  @override
  Stream<int> get chessRoomParticipantsCount =>
      _chessRoomParticipantsCountSC.stream;

  @override
  ChessRoom? currentRoom;

  @override
  int currentRoomParticipantsCount = 0;

  @override
  void createRoom({String? playerName}) {
    assert(currentRoom == null);
    assert(!_isJoining);
    connection.createRoom(playerName: playerName ?? "");
  }

  @override
  void joinRoom({required String code, String? playerName}) {
    assert(currentRoom == null);
    assert(!_isJoining);
    connection.joinRoom(playerName: playerName ?? "", code: code);
  }

  @override
  void leaveRoom() async {
    assert(currentRoom != null);
    connection.leaveRoom();
  }
}
