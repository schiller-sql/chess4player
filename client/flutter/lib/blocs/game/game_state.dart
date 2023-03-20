part of 'game_cubit.dart';

@immutable
abstract class GameState {
  const GameState();
}

class GameInitial extends GameState {}

class InGame extends GameState {
  const InGame();
}

class GameHasEnded extends GameState {
  final String gameEndReason;

  const GameHasEnded({required this.gameEndReason});
}
