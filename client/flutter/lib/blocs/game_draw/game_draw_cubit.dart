import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_draw_state.dart';

class GameDrawCubit extends Cubit<GameDrawState> {
  final IChessGameRepository chessGameRepository;

  GameDrawCubit({
    required this.chessGameRepository,
  }) : super(const GameDrawState(playerHasAcceptedDraw: false));

  void requestDraw() {
    emit(const GameDrawState(playerHasAcceptedDraw: true));
    chessGameRepository.requestDraw();
  }

  void acceptDraw() {
    emit(const GameDrawState(playerHasAcceptedDraw: true));
    chessGameRepository.acceptDraw();
  }
}
