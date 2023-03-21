import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> implements ChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;
  final IChessGameStartRepository chessGameStartRepository;
  late final StreamSubscription _chessGameStartSub;

  GameCubit({
    required this.chessGameStartRepository,
    required this.chessGameRepository,
  }) : super(GameInitial());

  void startListeningToGames() {
    emit(const InGame());
    _chessGameStartSub = chessGameStartRepository.gameStream.listen(_gameChange);
    chessGameRepository.addListener(this);
  }

  void _gameChange(Game? newGame) {
    if(newGame != null) {
      emit(const InGame());
    }
  }

  @override
  Future<void> close() async {
    chessGameRepository.removeListener(this);
    chessGameRepository.close();
    await _chessGameStartSub.cancel();
    return super.close();
  }

  @override
  void changed(IChessGameRepository chessGameRepository) {
    if(chessGameRepository.gameEnd != null) {
      emit(GameHasEnded(gameEndReason: chessGameRepository.gameEnd!));
    }
  }

  @override
  void timerChange(String player, Duration duration, bool hasStarted) {}
}
