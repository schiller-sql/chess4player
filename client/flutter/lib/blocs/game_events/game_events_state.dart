part of 'game_events_bloc.dart';

@immutable
abstract class GameEventsState {
  const GameEventsState();
}

class NoEvent extends GameEventsState {
  const NoEvent();
}

class ShowEvent extends GameEventsState {
  final GameEvent eventData;
  final Duration duration;

  const ShowEvent({
    required this.eventData,
    required this.duration,
  });
}
