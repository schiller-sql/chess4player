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

  void startListeningToGames() {
    gameStartRepository.connect();
    _sub = gameStartRepository.gameStream.listen(_change);
    _change(gameStartRepository.currentGame);
  }

  void _change(Game? game) {
    if(game != null) {
      emit(InGameState(game));
    }
  }

  void startGame(Duration timer) {
    emit(LoadingGameState());
    gameStartRepository.startGame(timer);
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
