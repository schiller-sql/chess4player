import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_draw_state.dart';

class GameDrawCubit extends Cubit<GameDrawState>
    with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;

  GameDrawCubit({
    required this.chessGameRepository,
  }) : super(const GameDrawState(canDraw: true));

  void startListeningToGame() {
    chessGameRepository.addListener(this);
  }

  void requestDraw() {
    emit(const GameDrawState(canDraw: false));
    chessGameRepository.requestDraw();
  }

  void acceptDraw() {
    emit(const GameDrawState(canDraw: false));
    chessGameRepository.acceptDraw();
  }

  @override
  void playerLost(String player, bool isSelf, String reason) {
    if(isSelf) {
      emit(const GameDrawState(canDraw: false));
    }
  }

  @override
  Future<void> close() {
    chessGameRepository.removeListener(this);
    return super.close();
  }
}
