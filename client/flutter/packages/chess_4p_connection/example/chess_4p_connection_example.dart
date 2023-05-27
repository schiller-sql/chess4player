import 'dart:async';

import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:chess_4p_connection/src/chess_connection/domain/turn.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  @override
  void gameStarted(Duration time, List<String?> playerOrder) {
    print("$name:\n");
    print("game started");
    print(time);
    print(playerOrder);
    print("\n\n");
  }

  @override
  void gameUpdate(
    String? gameEnd,
    List<Turn> turns,
  ) {
    print("gameUpdate");
    print("\n\n");
  }
}

void main() async {
  final connectionService = ChessConnection()
    ..connect(uri: 'ws://localhost:8080');
  await Future.delayed(Duration(seconds: 2));
  connectionService.createRoom(playerName: "deine mom");
  connectionService.addChessListener(ChessConnectionLogListener(name: "first"));

  await Future.delayed(Duration(seconds: 2));

  for (var i = 0; i < 4; i++) {
    final connectionService2 = ChessConnection()
      ..connect(uri: 'ws://localhost:8080');
    connectionService2.joinRoom(
        code: ChessConnectionLogListener.lastCreatedRoomCode,
        playerName: 'asa');
    // connectionService2.addChessListener(
    //   ChessConnectionLogListener(name: (i + 2).toString()),
    // );
  }
  await Future.delayed(Duration(seconds: 2));
  connectionService.startGame(duration: Duration(milliseconds: 200));
}

void main2() async {
  WebSocketChannel.connect(Uri.parse("ws://localhost:9999")).stream.listen(
    (event) {
      print(event);
    },
    onError: (error) {
      print("deinemom");
      print(error);
      print("deinemom");
    },
  );
}
