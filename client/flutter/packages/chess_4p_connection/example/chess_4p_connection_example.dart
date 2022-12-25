import 'dart:async';

import 'package:chess_4p_connection/chess_4p_connection.dart';

class ChessConnectionLogListener extends ChessConnectionListener {
  static late String lastCreatedRoomCode;

  final String name;

  ChessConnectionLogListener({required this.name});

  @override
  void createdRoom(String code, String name) {
    print("${this.name}:\n");
    print("created room:\n  code: $code, name: $name");
    print("\n\n");
    lastCreatedRoomCode = code;
  }

  @override
  void joinError(String error) {
    print("$name:\n");
    print("joined room:\n  error: $error");
    print("\n\n");
  }

  @override
  void joinedRoom(String name) {
    print("${this.name}:\n");
    print("joined room:\n  name: $name");
    print("\n\n");
  }

  @override
  void leftRoom(bool wasForced) {
    print("$name:\n");
    print("left room:\n  forced: $wasForced");
    print("\n\n");
  }

  @override
  void participantsCountUpdate(int count) {
    print("$name:\n");
    print("participantsCountUpdate: $count");
    print("\n\n");
  }
}

void main() async {
  final connectionService =
      ChessConnection(uri: Uri.parse('ws://localhost:8080'))..connect();
  connectionService.createRoom(playerName: "deine mom");
  connectionService.addChessListener(ChessConnectionLogListener(name: "first"));

  await Future.delayed(Duration(seconds: 2));

  for (var i = 0; i < 4; i++) {
    final connectionService2 = ChessConnection(
      uri: Uri.parse('ws://localhost:8080'),
    )..connect();
    connectionService2.joinRoom(
        code: ChessConnectionLogListener.lastCreatedRoomCode);
    connectionService2.addChessListener(
      ChessConnectionLogListener(name: (i + 2).toString()),
    );
  }
}
