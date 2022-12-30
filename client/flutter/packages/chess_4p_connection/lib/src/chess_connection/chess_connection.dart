import 'dart:async';
import 'dart:convert';

import 'package:chess_4p/chess_4p.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chess_connection_listener.dart';

/// A connection via websockets to /server,
/// which can be listened to by implementations of a [ChessConnectionListener]
class ChessConnection {
  final List<ChessConnectionListener> _listeners = [];
  final Uri uri;

  StreamSubscription<dynamic>? _sub;
  WebSocketChannel? _channel;

  bool get isConnected => _sub != null;

  /// Create a new [ChessConnection] that should connect to the [uri],
  /// which should be a websockets url,
  /// on which to find a four player chess server,
  /// which defines the protocol defined in /README.md or /protocol.txt
  ChessConnection({required this.uri});

  /// Connect via the [uri] given.
  ///
  /// After the initial [connect], a [close] should be called,
  /// after the connection is no longer needed
  /// and the [ChessConnection] object should be discarded.
  ///
  /// After the initial [connect] another [connect] cannot be called.
  Future<void> connect() {
    assert(_sub == null);
    _channel = WebSocketChannel.connect(uri);
    final connectionCompleter = Completer();
    _sub = _channel!.stream.listen(
      _handleEvent,
      onError: (error) {
        print(error);
        connectionCompleter.completeError(error);
        _channel!.sink.close();
        _sub!.cancel();
        _sub = null;
        _channel = null;
      },
      onDone: () {
        connectionCompleter.complete();
        _channel!.sink.close();
        _sub!.cancel();
        _sub!.cancel();
        _sub = null;
        _channel = null;
      },
      cancelOnError: false,
    );
    return connectionCompleter.future;
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

  /// Add [listener] to listen to the updates
  /// described in [ChessConnectionListener],
  /// if the listener is no longer required,
  /// it should be removed with [removeChessListener].
  ///
  /// If a object is added n times,
  /// it will have to be removed n times.
  void addChessListener(ChessConnectionListener listener) {
    _listeners.add(listener);
  }

  /// Remove [listener] from listening to the updates
  /// described in [ChessConnectionListener].
  ///
  /// For more information see [addChessListener].
  void removeChessListener(ChessConnectionListener listener) {
    _listeners.remove(listener);
  }

  /// Close the connection to the web-socket safely
  /// and remove all listeners.
  ///
  /// A [ChessConnection] can only be closed once.
  void close() {
    _channel?.sink.close();
    _sub?.cancel();
    _listeners.clear();
  }

  void _send(String type, String subtype, [Map<String, dynamic>? content]) {
    assert(isConnected);
    var string = '{'
        '"type":"$type",'
        '"subtype":"$subtype",'
        '"content":${content == null ? '{}' : jsonEncode(content)}'
        '}';
    _channel!.sink.add(string);
  }

  void _sendRoom(String subtype, [Map<String, dynamic>? content]) {
    _send("room", subtype, content);
  }

  void _sendGame(String subtype, [Map<String, dynamic>? content]) {
    _send("game", subtype, content);
  }

  /// See protocol: type: room, subtype: create
  void createRoom({required String playerName}) {
    _sendRoom("create", {"name": playerName});
  }

  /// See protocol: type: room, subtype: join
  void joinRoom({required String playerName, required String code}) {
    _sendRoom("join", {"name": playerName, "code": code});
  }

  /// See protocol: type: room, subtype: leave
  void leaveRoom() {
    _sendRoom("leave");
  }

  /// See protocol: type: game, subtype: start
  void startGame({required Duration duration}) {
    _sendGame("start", {"time": duration.inMilliseconds});
  }

  /// See protocol: type: game, subtype: move
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

  /// See protocol: type: game, subtype: resign
  void resignGame() {
    _sendGame("resign");
  }

  /// See protocol: type: game, subtype: draw-request
  void drawGameRequest() {
    _sendGame("draw-request");
  }

  /// See protocol: type: game, subtype: draw-accept
  void drawGameAccept() {
    _sendGame("draw-accept");
  }
}
