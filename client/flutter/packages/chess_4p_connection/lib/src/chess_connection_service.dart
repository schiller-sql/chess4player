import 'dart:async';
import 'dart:convert';

import 'package:chess_4p/chess_4p.dart';
import 'package:web_socket_channel/io.dart';

class ChessConnectionService {
  final List<ChessConnectionListener> _listeners = [];
  final IOWebSocketChannel channel;
  late final StreamSubscription<dynamic> sub;

  ChessConnectionService({required this.channel}) {
    _startListen();
  }

  void _startListen() {
    sub = channel.stream.listen(_event);
  }

  void _stopListen() {
    sub.cancel();
  }

  void _event(dynamic event) {
    print(event);
  }

  void addListener(ChessConnectionListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ChessConnectionListener listener) {
    _listeners.remove(listener);
  }

  void close() {
    _stopListen();
    _listeners.clear();
  }

  void _send(String type, String subtype, [Map<String, dynamic>? content]) {
    var string = '{'
        '"type":"$type",'
        '"subtype":"$subtype",'
        '"content":${content == null ? '{}' : jsonEncode(content)}'
        '}';
    channel.sink.add(string);
  }

  void _sendRoom(String subtype, [Map<String, dynamic>? content]) {
    _send("room", subtype, content);
  }

  void _sendGame(String subtype, [Map<String, dynamic>? content]) {
    _send("game", subtype, content);
  }

  void createRoom({required String playerName}) {
    _sendRoom("create", {"name": playerName});
  }

  void joinRoom({String playerName = "", required String code}) {
    _sendRoom("join", {"name": playerName, "code": code});
  }

  void leaveRoom() {
    _sendRoom("leave");
  }

  void startGame({required Duration duration}) {
    _sendGame("start", {"time": duration.inMilliseconds});
  }

  void movePiece({
    required int fromX,
    required int fromY,
    required int toX,
    required int toY,
    PieceType? promotion,
  }) {
    _sendGame(
      "move",
      {
        "move": [fromX, fromY, toX, toY],
        "promotion": promotion?.toSimpleString()
      },
    );
  }

  void resignGame() {
    _sendGame("resign");
  }

  void drawGameRequest() {
    _sendGame("draw");
  }

  void drawGameAccept() {
    _sendGame("draw-accept");
  }
}

abstract class ChessConnectionListener {
  void joinedRoom(bool isCreator, String name);

  void leftRoom(bool wasForced);

  void participantsCountUpdate(int count);

  void joinError(String error);
}
