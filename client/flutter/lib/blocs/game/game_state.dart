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
  final String ownName;
  final List<String> remainingPlayers;
  final Map<String, Direction> playerDirections;

  bool get isRemainingPlayer => remainingPlayers.contains(ownName);

  bool get singleWinner => remainingPlayers.length == 1;

  const GameHasEnded({
    required this.ownName,
    required this.gameEndReason,
    required this.remainingPlayers,
    required this.playerDirections,
  });
}
