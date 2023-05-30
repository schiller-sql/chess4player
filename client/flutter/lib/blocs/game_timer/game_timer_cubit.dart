import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'game_timer_state.dart';

class GameTimerCubit extends Cubit<GameTimerState> {
  GameTimerCubit() : super(const GameTimerState(timerDuration: Duration.zero));

  void setDefaultGameTime() {
    emit(const GameTimerState(timerDuration: Duration(minutes: 15)));
  }

  void setNewGameTimerDuration(Duration newTimerDuration) {
    emit(GameTimerState(timerDuration: newTimerDuration));
  }
}
