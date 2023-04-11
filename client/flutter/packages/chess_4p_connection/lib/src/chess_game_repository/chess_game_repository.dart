import 'package:chess_4p/chess_4p.dart';
import '../chess_connection/chess_connection_listener.dart';
import '../chess_connection/domain/lose_reason.dart';
import '../util/list_shift_extension.dart';

import '../chess_connection/chess_connection.dart';
import '../chess_connection/domain/turn.dart';
import '../chess_game_start_repository/domain/game.dart';
import 'chess_game_repository_contract.dart';
import 'domain/player.dart';

class ChessGameRepository extends ChessConnectionListener
    implements IChessGameRepository {
  @override
  bool get canMove =>
      playerOnTurn == game.ownPlayerPosition && !_lastUpdateNotAffirmed;
  bool _lastUpdateNotAffirmed = false;
  @override
  int playerOnTurn = 0;
  DateTime _playerOnTurnTime;
  @override
  final List<BoardUpdate<LoseReason>> updates = [];
  @override
  int firstNonImplementedUpdate = 0;
  @override
  String? gameEnd;

  @override
  final List<Player?> players;

  @override
  late final List<Player?> playersFromOwnPerspective;

  @override
  Board board;

  late BoardMover _boardMover;
  @override
  late BoardAnalyzer boardAnalyzer;

  final List<ChessGameRepositoryListener> _listeners = [];
  final ChessConnection connection;
  @override
  Game game;

  Player get _currentPlayer => players[playerOnTurn]!;

  static Board _boardFromGame(Game game) {
    return Board.standardWithOmission(
      game.playerOrder.map((player) => player != null).toList(growable: false),
      game.ownPlayerPosition,
    );
  }

  static List<Player?> _playersFromGame(Game game) {
    var index = -1;
    return game.playerOrder.map(
      (playerName) {
        index++;
        return playerName == null
            ? null
            : Player(
                name: playerName,
                remainingTime: game.time,
                colorDirection: Direction.fromInt(index),
                directionFromOwn: game.getDirectionFromPlayerName(playerName),
              );
      },
    ).toList(growable: false);
  }

  ChessGameRepository({
    required this.connection,
    required this.game,
  })  : board = _boardFromGame(game),
        players = _playersFromGame(game),
        _playerOnTurnTime = DateTime.now() {
    _boardMover = BoardMover(board: board);
    boardAnalyzer = BoardAnalyzer(
      board: board,
      analyzingDirection: Direction.up,
    );
    players[0]!.isOnTurn = true;
    playersFromOwnPerspective = players.shift(game.ownPlayerPosition);
  }

  @override
  void connect() {
    connection.addChessListener(this);
  }

  @override
  void close() {
    connection.removeChessListener(this);
  }

  void _changed() {
    for (final listener in _listeners) {
      listener.changed(this);
    }
  }

  void _sendListenersTimeUpdate(
    String player,
    Duration duration,
    bool hasStarted,
  ) {
    for (var listener in _listeners) {
      listener.timerChange(player, duration, hasStarted);
    }
  }

  @override
  void addListener(ChessGameRepositoryListener listener) {
    _listeners.add(listener);
    if (gameEnd == null) {
      final durationBetweenLastMove =
          DateTime.now().difference(_playerOnTurnTime);
      final timeOfCurrentPlayer =
          _currentPlayer.remainingTime - durationBetweenLastMove;
      _sendListenersTimeUpdate(_currentPlayer.name, timeOfCurrentPlayer, true);
    }
  }

  @override
  void removeListener(ChessGameRepositoryListener listener) {
    _listeners.remove(listener);
  }

  @override
  void gameUpdate(
    String? gameEnd,
    List<Turn> turns,
  ) {
    final playerOfUpdate = _currentPlayer;
    _currentPlayer.isOnTurn = false;
    _playerOnTurnTime = DateTime.now();
    for (var turnIndex = 0; turnIndex < turns.length; turnIndex++) {
      final turn = turns[turnIndex];
      _sendListenersTimeUpdate(
        _currentPlayer.name,
        turn.remainingTime,
        false,
      );
      _currentPlayer.remainingTime = turn.remainingTime;
      // don't go to next player, if the game ends
      if (turnIndex < turns.length - 1 || gameEnd == null) {
        // go to next player
        do {
          playerOnTurn++;
          if (playerOnTurn == 4) {
            playerOnTurn = 0;
          }
        } while (players[playerOnTurn] == null ||
            players[playerOnTurn]?.lostReason != null);
      }
    }
    _currentPlayer.isOnTurn = true;
    if (gameEnd == null) {
      _sendListenersTimeUpdate(
        _currentPlayer.name,
        _currentPlayer.remainingTime,
        true,
      );
    }
    if (_lastUpdateNotAffirmed) {
      final update = updates[updates.length - 1];
      if (firstNonImplementedUpdate == updates.length) {
        _boardMover.reverseApplyBoardUpdate(update);
        firstNonImplementedUpdate--;
      }
      updates.removeLast();
      _lastUpdateNotAffirmed = false;
    }
    this.gameEnd = gameEnd;
    for (final turn in turns) {
      for (final listener in _listeners) {
        listener.playersLost(turn.lostPlayers);
      }
      turn.lostPlayers.forEach((name, lostReason) {
        for (final player in players) {
          if (player == null) continue;
          if (player.name == name) {
            player.lostReason = lostReason;
          }
        }
      });
    }
    for (final turn in turns) {
      final List<Move> moves;
      if (turn.move != null) {
        final from = turn.move!.from.rotateClockwiseBy(-game.ownPlayerPosition);
        final to = turn.move!.to.rotateClockwiseBy(-game.ownPlayerPosition);
        moves = _boardMover.analyseMoves(
          from.x,
          from.y,
          to.x,
          to.y,
          turn.move!.promotion,
        );
      } else {
        moves = [];
      }
      final eliminatedPlayers = turn.lostPlayers.map((playerName, loseReason) => MapEntry(
          game.getDirectionFromPlayerName(playerName), loseReason,
      ));
      final update = BoardUpdate(
        moves: moves,
        playerDirection: playerOfUpdate.directionFromOwn,
        eliminatedPlayers: eliminatedPlayers,
      );
      _addNewBoardUpdate(update);
    }
    _changed();
    if (gameEnd != null) {
      final remainingPlayers = players
          .where((player) => player != null)
          .cast<Player>()
          .where((player) => !player.hasLost)
          .map((player) => player.name)
          .toList(growable: false);
      for (final listener in _listeners) {
        listener.gameEnd(
          gameEnd,
          remainingPlayers,
        );
      }
    }
  }

  void _addNewBoardUpdate(BoardUpdate<LoseReason> update) {
    if (firstNonImplementedUpdate == updates.length) {
      firstNonImplementedUpdate++;
      _boardMover.applyBoardUpdate(update);
    }
    updates.add(update);
  }

  @override
  void playerResign(String playerName) {
    for (var player in players) {
      if (player?.name == playerName) {
        player?.lostReason = LoseReason.resign;
      }
    }
    final lostPlayers = {playerName: LoseReason.resign};
    for (final listener in _listeners) {
      listener.playersLost(lostPlayers);
    }
    final playerDirection = game.getDirectionFromPlayerName(playerName);
    final update = BoardUpdate(
      moves: [],
      eliminatedPlayers: {playerDirection: LoseReason.resign},
    );
    if (_lastUpdateNotAffirmed) {
      final lastUpdate = updates.removeLast();
      _addNewBoardUpdate(update);
      updates.add(lastUpdate);
    } else {
      _addNewBoardUpdate(update);
    }
    _changed();
  }

  @override
  bool moveIsPromotion(Field from, Field to) {
    return _boardMover.analyzeMoveIsPromotion(from.x, from.y, to.x, to.y);
  }

  @override
  void move(Field from, Field to, [PieceType? promotion]) {
    final moves = _boardMover.analyseMoves(
      from.x,
      from.y,
      to.x,
      to.y,
      promotion,
    );
    final update = BoardUpdate(
      moves: moves,
      eliminatedPlayers: <Direction, LoseReason>{},
      playerDirection: Direction.up,
    );
    _addNewBoardUpdate(update);
    _lastUpdateNotAffirmed = true;
    _changed();
    final fromTurned = from.rotateClockwiseBy(game.ownPlayerPosition);
    final toTurned = to.rotateClockwiseBy(game.ownPlayerPosition);
    connection.movePiece(
      fromX: fromTurned.x,
      fromY: fromTurned.y,
      toX: toTurned.x,
      toY: toTurned.y,
      promotion: promotion,
    );
  }

  @override
  void resign() {
    connection.resignGame();
  }

  @override
  void drawRequest(String requesterName) {
    final ownPlayer = playersFromOwnPerspective[0]!;
    if (ownPlayer.hasLost) return;
    final ownName = ownPlayer.name;
    final isRequester = ownName == requesterName;
    for (final listener in _listeners) {
      listener.drawRequest(requesterName, isRequester);
    }
  }

  bool _hasAcceptedDraw = false;

  @override
  void acceptDraw() {
    if (_hasAcceptedDraw) return;
    _hasAcceptedDraw = true;
    connection.drawGameAccept();
  }

  @override
  void requestDraw() {
    if (_hasAcceptedDraw) return;
    _hasAcceptedDraw = true;
    connection.drawGameRequest();
  }
}
