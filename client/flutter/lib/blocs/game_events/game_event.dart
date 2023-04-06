part of 'game_events_bloc.dart';

class GameEvent {}

class PlayerLostEvent extends GameEvent {
  final bool isSelf;
  final String playerName;
  final String reason;

  PlayerLostEvent({
    required this.isSelf,
    required this.playerName,
    required this.reason,
  });
}

class DrawRequestEvent extends GameEvent {
  final bool selfRequested;
  final String playerName;

  DrawRequestEvent({
    required this.selfRequested,
    required this.playerName,
  });
}
