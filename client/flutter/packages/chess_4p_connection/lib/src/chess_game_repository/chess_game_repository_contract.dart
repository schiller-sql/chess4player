import 'package:chess_4p/chess_4p.dart';

import '../chess_connection/domain/lose_reason.dart';
import '../chess_game_start_repository/domain/game.dart';
import 'domain/player.dart';

abstract class ChessGameRepositoryListener {
  void changed(IChessGameRepository chessGameRepository);

  void timerChange(String player, Duration duration, bool hasStarted);

  void drawRequest(String player, bool isOwnRequest);

  void playerLost(String player, bool isSelf, LoseReason reason);
}

mixin DefaultChessGameRepositoryListener
    implements ChessGameRepositoryListener {
  @override
  void changed(IChessGameRepository chessGameRepository) {}

  @override
  void timerChange(String player, Duration duration, bool hasStarted) {}

  @override
  void drawRequest(String player, bool isOwnRequest) {}

  @override
  void playerLost(String player, bool isSelf, LoseReason reason) {}
}

abstract class IChessGameRepository {
  List<BoardUpdate> get updates;
  bool get canMove;
  int get playerOnTurn;
  List<Player?> get players;
  List<Player?> get playersFromOwnPerspective;
  int get firstNonImplementedUpdate;
  ReadableBoard get board;
  String? get gameEnd;
  Game get game;

  BoardAnalyzer get boardAnalyzer;

  void connect();

  void close();

  void move(Field from, Field to, [PieceType? promotion]);

  bool moveIsPromotion(Field from, Field to);

  void addListener(ChessGameRepositoryListener listener);

  void removeListener(ChessGameRepositoryListener listener);

  void resign();

  void acceptDraw();

  void requestDraw();
}
