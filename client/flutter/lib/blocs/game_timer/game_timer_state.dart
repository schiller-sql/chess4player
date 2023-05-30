part of 'game_timer_cubit.dart';

@immutable
class GameTimerState {
  final Duration timerDuration;

  bool get isValid => timerDuration.inMicroseconds > 0;

  const GameTimerState({required this.timerDuration});
}
