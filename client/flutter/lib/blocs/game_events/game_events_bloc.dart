import 'package:bloc/bloc.dart';
import 'package:chess_4p/chess_4p.dart';
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
    on<DrawRequestEvent>((event, emit) {
      final Duration duration;
      if (event.isSelf) {
        duration = const Duration(milliseconds: 4000);
      } else {
        duration = const Duration(milliseconds: 15000);
      }
      emit(ShowEvent(duration: duration, eventData: event));
      return Future.delayed(duration);
    });
    on<PlayerLostEvent>((event, emit) {
      final Duration duration;
      if (event.isSelf) {
        duration = const Duration(milliseconds: 4000);
      } else {
        duration = const Duration(milliseconds: 7000);
      }
      emit(ShowEvent(eventData: event, duration: duration));
      return Future.delayed(duration);
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

  Direction playerDirectionFromName(String playerName) {
    final playerIndex = chessGameRepository.players
        .indexWhere((player) => player?.name == playerName);
    return Direction.fromInt(playerIndex);
  }

  @override
  void drawRequest(String player, bool isOwnRequest) {
    add(
      DrawRequestEvent(
        isSelf: isOwnRequest,
        playerName: player,
        playerDirection: playerDirectionFromName(player),
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
        playerDirection: playerDirectionFromName(player),
      ),
    );
  }
}
