import 'dart:async';

import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:web_socket_channel/io.dart';

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
  var channel = IOWebSocketChannel.connect(Uri.parse('ws://localhost:8080'));

  final connectionService = ChessConnectionService(channel: channel);
  connectionService.createRoom(playerName: "deine mom");
  connectionService.addListener(ChessConnectionLogListener(name: "first"));

  await Future.delayed(Duration(seconds: 2));

  for (var i = 0; i < 4; i++) {
    var channel2 = IOWebSocketChannel.connect(Uri.parse('ws://localhost:8080'));

    final connectionService2 = ChessConnectionService(channel: channel2);
    connectionService2.joinRoom(
        code: ChessConnectionLogListener.lastCreatedRoomCode);
    connectionService2.addListener(
      ChessConnectionLogListener(name: (i + 2).toString()),
    );
  }
}
