import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_draw_state.dart';

class GameDrawCubit extends Cubit<GameDrawState>
    with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;

  GameDrawCubit({
    required this.chessGameRepository,
  }) : super(const GameDrawState());

  void startListeningToGame() {
    chessGameRepository.addListener(this);
  }

  void requestDraw() {
    emit(const GameDrawState(didAcceptDraw: true));
    chessGameRepository.requestDraw();
  }

  void acceptDraw() {
    emit(const GameDrawState(didAcceptDraw: true));
    chessGameRepository.acceptDraw();
  }

  @override
  void playersLost(Map<String, LoseReason> players) {
    final ownName = chessGameRepository.playersFromOwnPerspective[0]!.name;
    final isSelf = players.containsKey(ownName);
    if (isSelf) {
      emit(const GameDrawState(didLose: true));
    }
  }

  @override
  Future<void> close() {
    chessGameRepository.removeListener(this);
    return super.close();
  }
}
