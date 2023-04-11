part of 'game_events_bloc.dart';

abstract class GameEvent {
  final String playerName;
  final Direction playerDirection;
  final bool isSelf;

  GameEvent({
    required this.isSelf,
    required this.playerName,
    required this.playerDirection,
  });
}

class PlayerLostEvent extends GameEvent {
  final LoseReason reason;

  PlayerLostEvent({
    required this.reason,
    required super.isSelf,
    required super.playerName,
    required super.playerDirection,
  });
}

class DrawRequestEvent extends GameEvent {
  DrawRequestEvent({
    required super.isSelf,
    required super.playerName,
    required super.playerDirection,
  });
}
