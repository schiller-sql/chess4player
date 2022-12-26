import 'dart:async';

import '../chess_connection/chess_connection.dart';
import '../chess_connection/chess_connection_listener.dart';
import 'chess_room_repository_contract.dart';
import 'domain/room.dart';
import 'domain/room_update.dart';
import 'domain/room_update_type.dart';
import 'errors/room_join_exception.dart';

class ChessRoomRepository
    implements IChessRoomRepository, ChessConnectionListener {
  bool _isJoining = false;
  bool _isLeaving = false;
  late String _lastCodeToJoin;

  final ChessConnection connection;

  ChessRoomRepository(this.connection);

  @override
  void createdRoom(String code, String name) {
    _participantsCountChange(1);
    assert(!_isLeaving);
    assert(_isJoining);
    _isJoining = false;
    _roomUpdate(
      RoomUpdate(
        chessRoom: ChessRoom(code: code, playerName: name, isAdmin: true),
        updateType: RoomUpdateType.join,
      ),
    );
  }

  @override
  void joinError(String error) {
    assert(!_isLeaving);
    assert(_isJoining);
    _isJoining = false;
    _roomSC.addError(RoomJoinException(error));
  }

  @override
  void joinedRoom(String name) {
    assert(!_isLeaving);
    assert(_isJoining);
    _isJoining = false;
    _roomUpdate(
      RoomUpdate(
        chessRoom: ChessRoom(
          code: _lastCodeToJoin,
          playerName: name,
          isAdmin: false,
        ),
        updateType: RoomUpdateType.join,
      ),
    );
  }

  @override
  void leftRoom(bool wasForced) {
    assert(!_isJoining);
    assert(_isLeaving);
    assert(currentRoom == null);

    _isLeaving = false;
    _roomUpdate(
      RoomUpdate(
        chessRoom: currentRoom!,
        updateType: wasForced ? RoomUpdateType.leave : RoomUpdateType.forceLeave,
      ),
    );
  }

  @override
  void participantsCountUpdate(int count) {
    assert(currentRoom != null);
    assert(currentRoom!.isAdmin);

    _participantsCountChange(count);
  }

  void _roomUpdate(RoomUpdate update) {
    _roomSC.add(update);
    currentRoom = update.chessRoom;
  }

  void _participantsCountChange(int newCount) {
    _chessRoomParticipantsCountSC.add(newCount);
    currentRoomParticipantsCount = newCount;
  }

  final StreamController<RoomUpdate> _roomSC = StreamController.broadcast();

  @override
  Stream<RoomUpdate> get roomUpdateStream => _roomSC.stream;

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
    assert(!_isLeaving);
    connection.createRoom(playerName: playerName ?? "");
  }

  @override
  void joinRoom({required String code, String? playerName}) {
    assert(currentRoom == null);
    assert(!_isJoining);
    assert(!_isLeaving);
    _lastCodeToJoin = code;
    connection.joinRoom(playerName: playerName ?? "", code: code);
  }

  @override
  void leaveRoom() async {
    assert(currentRoom != null);
    _isLeaving = true;
    connection.leaveRoom();
  }
}