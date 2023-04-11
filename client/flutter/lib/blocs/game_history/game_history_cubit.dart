import 'package:bloc/bloc.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_history_state.dart';

class GameHistoryCubit extends Cubit<GameHistoryState>
    with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;

  GameHistoryCubit({
    required this.chessGameRepository,
  }) : super(const GameHistoryState.empty());

  void startListeningToGame() {
    chessGameRepository.addListener(this);
  }

  @override
  void changed(IChessGameRepository chessGameRepository) {
    emit(
      GameHistoryState(
        updates: ReverseSubListView(
          chessGameRepository.updates,
          0,
          chessGameRepository.updates.length,
        ),
        ownPosition: chessGameRepository.game.ownPlayerPosition,
        playersFromOwnPosition: chessGameRepository.playersFromOwnPerspective,
      ),
    );
  }

  @override
  Future<void> close() {
    chessGameRepository.removeListener(this);
    return super.close();
  }
}
