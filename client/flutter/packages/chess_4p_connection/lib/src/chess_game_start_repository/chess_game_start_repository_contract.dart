import 'domain/game.dart';

abstract class IChessGameStartRepository {
  Stream<Game?> get gameStream;

  Game? get currentGame;

  void startGame(Duration playerTime);

  void connect();

  void close();
}