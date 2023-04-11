import 'dart:async';

import 'package:chess_4p_connection/src/chess_game_start_repository/domain/game.dart';

import '../chess_connection/chess_connection.dart';
import '../chess_connection/chess_connection_listener.dart';
import '../chess_connection/domain/turn.dart';
import 'chess_game_start_repository_contract.dart';

class ChessGameStartRepository extends ChessConnectionListener
    implements IChessGameStartRepository {
  final ChessConnection connection;
  String playerName;

  ChessGameStartRepository({
    required this.connection,
    required this.playerName,
  });

  @override
  void connect() {
    connection.addChessListener(this);
  }

  @override
  void close() {
    connection.removeChessListener(this);
  }

  @override
  Game? currentGame;

  final StreamController<Game?> _gameController =
      StreamController.broadcast(sync: true);

  void _updateGame(Game? newGame) {
    _gameController.add(newGame);
    currentGame = newGame;
  }

  @override
  Stream<Game?> get gameStream => _gameController.stream;

  @override
  void startGame(Duration playerTime) {
    connection.startGame(duration: playerTime);
  }

  @override
  void gameStarted(Duration time, List<String?> playerOrder) {
    _updateGame(
      Game(
        time: time,
        playerOrder: playerOrder,
        ownPlayerPosition: playerOrder.lastIndexOf(playerName),
      ),
    );
  }

  @override
  void gameUpdate(
    String? gameEnd,
    List<Turn> turns,
  ) {
    if (gameEnd != null) {
      _updateGame(null);
    }
  }

  @override
  void createdRoom(String code, String name) {
    playerName = name;
  }

  @override
  void joinedRoom(String name) {
    playerName = name;
  }
}
