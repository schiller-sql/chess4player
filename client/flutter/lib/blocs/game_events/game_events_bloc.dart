import 'package:bloc/bloc.dart';
import 'package:chess_4p/chess_4p.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'game_events_state.dart';
part 'game_event.dart';

class GameEventsBloc extends Cubit<GameEventsState>
    with DefaultChessGameRepositoryListener {
  final IChessGameRepository chessGameRepository;

  GameEventsBloc({
    required this.chessGameRepository,
  }) : super(const NoEvent());

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
    final event = DrawRequestEvent(
      isSelf: isOwnRequest,
      playerName: player,
      playerDirection: playerDirectionFromName(player),
    );
    final Duration duration;
    if (event.isSelf) {
      duration = const Duration(milliseconds: 4000);
    } else {
      duration = const Duration(milliseconds: 15000);
    }
    emit(ShowEvent(duration: duration, eventData: event));
  }

  @override
  void playersLost(Map<String, LoseReason> players) async {
    final ownName = chessGameRepository.playersFromOwnPerspective[0]!.name;
    for(final playerName in players.keys) {
      final isSelf = playerName == ownName;
      final loseReason = players[playerName];
      final event = PlayerLostEvent(
        isSelf: isSelf,
        playerName: playerName,
        reason: loseReason!,
        playerDirection: playerDirectionFromName(playerName),
      );
      final Duration duration;
      if (isSelf) {
        duration = const Duration(milliseconds: 4000);
      } else {
        duration = const Duration(milliseconds: 7000);
      }
      emit(ShowEvent(eventData: event, duration: duration));
      await Future.delayed(duration);
    }
  }

  @override
  void gameEnd(String reason, List<String> remainingPlayers) {
    final state = this.state;
    if (state is ShowEvent && state.eventData is DrawRequestEvent) {
      emit(const NoEvent());
    }
  }
}
