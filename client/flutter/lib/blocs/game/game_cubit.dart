import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState>
    with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;
  final IChessGameStartRepository chessGameStartRepository;
  late final StreamSubscription _chessGameStartSub;

  GameCubit({
    required this.chessGameStartRepository,
    required this.chessGameRepository,
  }) : super(GameInitial());

  void startListeningToGames() {
    emit(const InGame());
    _chessGameStartSub =
        chessGameStartRepository.gameStream.listen(_gameChange);
    chessGameRepository.addListener(this);
  }

  void _gameChange(Game? newGame) {
    if (newGame != null) {
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
  void gameEnd(
    String reason,
    List<String> remainingPlayers,
  ) {
    final playerDirections = <String, Direction>{};
    for (var i = 0; i < 4; i++) {
      final player = chessGameRepository.players[i];
      if (player != null) {
        playerDirections[player.name] = Direction.fromInt(i);
      }
    }
    emit(
      GameHasEnded(
        ownName: chessGameRepository.playersFromOwnPerspective[0]!.name,
        gameEndReason: chessGameRepository.gameEnd!,
        remainingPlayers: remainingPlayers,
        playerDirections: playerDirections,
      ),
    );
  }

  @override
  void timerChange(String player, Duration duration, bool hasStarted) {}
}
