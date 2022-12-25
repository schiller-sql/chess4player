import 'dart:async';
import 'dart:convert';

import 'package:chess_4p/chess_4p.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chess_connection_listener.dart';

class ChessConnection {
  final List<ChessConnectionListener> _listeners = [];
  final WebSocketChannel _channel;
  final Uri uri;
  late final StreamSubscription<dynamic> _sub;

  final Completer<bool> _connectionCompleter = Completer();

  Future<bool> get connectionClosedWithError => _connectionCompleter.future;

  ChessConnection({required this.uri})
      : _channel = WebSocketChannel.connect(uri);

  void connect() {
    _sub = _channel.stream.listen(
      _handleEvent,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: false,
    );
  }

  void _handleError(Object error) {
    _handleFinish(true);
  }

  void _handleDone() {
    _handleFinish(false);
  }

  void _handleFinish(bool withError) {
    _connectionCompleter.complete(withError);
    close();
  }

  void _handleEvent(dynamic rawEvent) {
    Map<String, dynamic> event = jsonDecode(rawEvent);
    final type = event["type"];
    final subtype = event["subtype"];
    final content = event["content"] ?? const <String, dynamic>{};
    switch (type) {
      case "room":
        switch (subtype) {
          case "created":
            final code = content["code"]!;
            final name = content["name"]!;
            for (final listener in _listeners) {
              listener.createdRoom(code, name);
            }
            break;
          case "joined":
            final name = content["name"]!;
            for (final listener in _listeners) {
              listener.joinedRoom(name);
            }
            break;
          case "join-failed":
            final reason = content["reason"]!;
            for (final listener in _listeners) {
              listener.joinError(reason);
            }
            break;
          case "left":
            for (final listener in _listeners) {
              listener.leftRoom(false);
            }
            break;
          case "disbanded":
            for (final listener in _listeners) {
              listener.leftRoom(true);
            }
            break;
          case "participants-count-update":
            final participantsCount = content["participants-count"]!;
            for (final listener in _listeners) {
              listener.participantsCountUpdate(participantsCount);
            }
            break;
        }
        break;
      case "game":
        switch (subtype) {
        }
        break;
    }
  }

  void addChessListener(ChessConnectionListener listener) {
    _listeners.add(listener);
  }

  void removeChessListener(ChessConnectionListener listener) {
    _listeners.remove(listener);
  }

  void close() {
    _channel.sink.close();
    _sub.cancel();
    _listeners.clear();
  }

  void _send(String type, String subtype, [Map<String, dynamic>? content]) {
    var string = '{'
        '"type":"$type",'
        '"subtype":"$subtype",'
        '"content":${content == null ? '{}' : jsonEncode(content)}'
        '}';
    _channel.sink.add(string);
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
