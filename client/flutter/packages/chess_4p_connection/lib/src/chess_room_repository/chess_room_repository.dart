import 'dart:async';

import 'package:chess_4p_connection/src/chess_room_repository/errors/room_disbanded_exception.dart';

import '../chess_connection/chess_connection.dart';
import '../chess_connection/chess_connection_listener.dart';
import 'chess_room_repository_contract.dart';
import 'domain/room.dart';
import 'domain/room_update.dart';
import 'domain/room_update_type.dart';
import 'errors/room_join_exception.dart';

class ChessRoomRepository extends ChessConnectionListener
    implements IChessRoomRepository {
  @override
  bool isJoiningRoom = false;

  bool _isLeaving = false;
  late String _lastCodeToJoin;

  final ChessConnection connection;

  ChessRoomRepository({required this.connection}) {
    connection.addChessListener(this); // TODO: WTF?
  }

  @override
  void createdRoom(String code, String name) async {
    _participantsCountChange(1);
    assert(!_isLeaving);
    assert(isJoiningRoom);
    isJoiningRoom = false;
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
    assert(isJoiningRoom);
    isJoiningRoom = false;
    _roomSC.addError(RoomJoinException.fromErrorMessage(error));
    currentRoom = null;
  }

  @override
  void joinedRoom(String name) {
    assert(!_isLeaving);
    assert(isJoiningRoom);
    isJoiningRoom = false;
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
    assert(!isJoiningRoom);
    if (!wasForced) {
      assert(_isLeaving);
    }
    assert(currentRoom != null);

    _isLeaving = false;
    _roomUpdate(
      RoomUpdate(
        chessRoom: currentRoom!,
        updateType: RoomUpdateType.leave,
      ),
    );
    if (wasForced) {
      _roomSC.addError(RoomDisbandedException());
    }
  }

  @override
  void participantsCountUpdate(int count) {
    assert(currentRoom != null);
    assert(currentRoom!.isAdmin);

    _participantsCountChange(count);
  }

  void _roomUpdate(RoomUpdate update) {
    _roomSC.add(update);
    if (update.updateType == RoomUpdateType.leave) {
      currentRoom = null;
    } else {
      currentRoom = update.chessRoom;
    }
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
    assert(!isJoiningRoom);
    assert(!_isLeaving);
    isJoiningRoom = true;
    connection.createRoom(playerName: playerName ?? "");
    _roomUpdate(
      RoomUpdate(
        chessRoom: ChessRoom(
          code: '',
          playerName: playerName ?? "",
          isAdmin: true,
        ),
        updateType: RoomUpdateType.joining,
      ),
    );
  }

  @override
  void joinRoom({required String code, String? playerName}) {
    assert(currentRoom == null);
    assert(!isJoiningRoom);
    assert(!_isLeaving);
    isJoiningRoom = true;
    _lastCodeToJoin = code;
    connection.joinRoom(playerName: playerName ?? "", code: code);
    _roomUpdate(
      RoomUpdate(
        chessRoom: ChessRoom(
          code: code,
          playerName: playerName ?? "",
          isAdmin: false,
        ),
        updateType: RoomUpdateType.joining,
      ),
    );
  }

  @override
  void leaveRoom() async {
    assert(currentRoom != null);
    _isLeaving = true;
    connection.leaveRoom();
  }

  void close() {
    connection.removeChessListener(this);
  }

  @override
  void resetCurrentRoom() {
    _isLeaving = false;
    isJoiningRoom = false;
    _lastCodeToJoin = "";
    if (currentRoom != null) {
      _roomUpdate(
        RoomUpdate(
          chessRoom: currentRoom!,
          updateType: RoomUpdateType.leave,
        ),
      );
    }
  }
}
