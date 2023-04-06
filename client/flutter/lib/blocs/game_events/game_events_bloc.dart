import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_events_state.dart';
part 'game_event.dart';

class GameEventsBloc extends Bloc<GameEvent, GameEventsState>
    with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;

  GameEventsBloc({
    required this.chessGameRepository,
  }) : super(const NoEvent()) {
    on<DrawRequestEvent>((event, emit) async {
      emit(ShowEvent(event));
      await Future.delayed(const Duration(milliseconds: 5000));
      emit(const NoEvent());
    });
    on<PlayerLostEvent>((event, emit) async {
      emit(ShowEvent(event));
      await Future.delayed(const Duration(milliseconds: 1000));
      emit(const NoEvent());
    });
  }

  void startListeningToGame() {
    chessGameRepository.addListener(this);
  }

  @override
  Future<void> close() {
    chessGameRepository.removeListener(this);
    return super.close();
  }

  @override
  void drawRequest(String player, bool isOwnRequest) {
    add(
      DrawRequestEvent(
        selfRequested: isOwnRequest,
        playerName: player,
      ),
    );
  }

  @override
  void playerLost(String player, bool isSelf, String reason) {
    add(
      PlayerLostEvent(
        isSelf: isSelf,
        playerName: player,
        reason: reason,
      ),
    );
  }
}
