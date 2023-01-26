part of 'join_game_cubit.dart';

@immutable
abstract class JoinGameState {}

class InGameState extends JoinGameState {
  final Game game;

  InGameState(this.game);
}

class InNoGameState extends JoinGameState {

}

class LoadingGameState extends JoinGameState {

}
