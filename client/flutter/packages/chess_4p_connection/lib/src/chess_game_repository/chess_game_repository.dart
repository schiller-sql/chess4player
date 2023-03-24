import 'package:chess_4p/chess_4p.dart';
import 'package:chess_4p_connection/src/chess_game_repository/chess_game_repository_contract.dart';

import '../chess_connection/chess_connection.dart';
import '../chess_connection/chess_connection_listener.dart';
import '../chess_connection/domain/turn.dart';
import '../chess_game_start_repository/domain/game.dart';
import 'domain/player.dart';

class ChessGameRepository extends ChessConnectionListener
    implements IChessGameRepository {
  bool _lastUpdateNotAffirmed = false;
  @override
  int playerOnTurn = 0;
  @override
  final List<BoardUpdate> updates = [];
  @override
  int firstNonImplementedUpdate = 0;
  @override
  String? gameEnd;

  @override
  List<Player?> players;

  @override
  Board board;

  late BoardMover _boardMover;
  @override
  late BoardAnalyzer boardAnalyzer;

  final List<ChessGameRepositoryListener> _listeners = [];
  final ChessConnection connection;
  @override
  Game game;

  static Board _boardFromGame(Game game) {
    return Board.standardWithOmission(
      game.playerOrder.map((player) => player != null).toList(growable: false),
      game.ownPlayerPosition,
    );
  }

  static List<Player?> _playersFromGame(Game game) {
    return game.playerOrder
        .map(
          (playerName) => playerName == null
              ? null
              : Player(
                  name: playerName,
                  remainingTime: game.time,
                ),
        )
        .toList(growable: false);
  }

  ChessGameRepository({
    required this.connection,
    required this.game,
  })  : board = _boardFromGame(game),
        players = _playersFromGame(game) {
    _boardMover = BoardMover(board: board);
    boardAnalyzer = BoardAnalyzer(
      board: board,
      analyzingDirection: Direction.up,
    );
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

  @override
  void addListener(ChessGameRepositoryListener listener) {
    _listeners.add(listener);
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
    var howManyTurnsPlayed = turns.length;
    if (gameEnd != null) {
      howManyTurnsPlayed--;
    }
    var turnIndex = 0;
    while (howManyTurnsPlayed > 0) {
      howManyTurnsPlayed--;
      do {
        playerOnTurn++;
        if (playerOnTurn == 4) {
          playerOnTurn = 0;
        }
      } while (players[playerOnTurn] == null ||
          players[playerOnTurn]?.lostReason != null);
      players[playerOnTurn]?.remainingTime = turns[turnIndex].remainingTime;
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
      Set<Direction> eliminatedPlayers = turn.lostPlayers.keys
          .map(
            (playerName) => game.getDirectionFromPlayerName(playerName),
          )
          .toSet();
      final update = BoardUpdate(
        moves: moves,
        eliminatedPlayers: eliminatedPlayers,
      );
      _addNewBoardUpdate(update);
    }
    _changed();
  }

  void _addNewBoardUpdate(BoardUpdate update) {
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
        player?.lostReason = "resign";
      }
    }
    final playerDirection = game.getDirectionFromPlayerName(playerName);
    final update = BoardUpdate(
      moves: [],
      eliminatedPlayers: {playerDirection},
    );
    if(_lastUpdateNotAffirmed) {
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
    final update = BoardUpdate(moves: moves, eliminatedPlayers: {});
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
  void restart(Game game) {
    // TODO: deprecate
    throw UnimplementedError("Should not be used, will maybe be deprecated");
    this.game = game;
    players = _playersFromGame(game);
    board = _boardFromGame(game);
    _boardMover = BoardMover(board: board);
    boardAnalyzer = BoardAnalyzer(
      board: board,
      analyzingDirection: Direction.up,
    );
    _changed();
  }
}
