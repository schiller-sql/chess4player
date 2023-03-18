import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'join_game_state.dart';

class JoinGameCubit extends Cubit<JoinGameState> {
  final IChessGameStartRepository gameStartRepository;
  late final StreamSubscription _sub;

  JoinGameCubit({
    required this.gameStartRepository,
  }) : super(InNoGameState());

  void startListeningToGame() {
    gameStartRepository.connect();
    _sub = gameStartRepository.gameStream.listen(_change);
    _change(gameStartRepository.currentGame);
  }

  void _change(Game? game) {
    if(game != null) {
      emit(InGameState(game));
    }
  }

  Duration _time = const Duration(minutes: 15);

  void changeTimeSettings(Duration time) {
    _time = time;
  }

  void startGame() {
    emit(LoadingGameState());
    gameStartRepository.startGame(_time);
  }

  void leaveGame() {
    emit(InNoGameState());
  }

  @override
  Future<void> close() async {
    await super.close();
    await _sub.cancel();
    gameStartRepository.close();
  }
}
