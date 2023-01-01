import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'join_room_state.dart';

class JoinRoomCubit extends Cubit<JoinRoomState> {
  final IChessRoomRepository roomRepository;
  final IChessConnectionRepository connectionRepository;
  late final StreamSubscription _conSub;

  JoinRoomCubit({
    required this.roomRepository,
    required this.connectionRepository,
  }) : super(const JoinRoomState.initial());

  void startListeningToConnection() {
    emit(
      JoinRoomState(
        code: "",
        validCode: false,
        canConnect: connectionRepository.currentConnectionStatus.type ==
            ConnectionStatusType.connected,
      ),
    );
    _conSub =
        connectionRepository.connectionStatus.listen(_connectionStatusUpdate);
  }

  void _connectionStatusUpdate(ConnectionStatus status) {
    final canConnect = status.type == ConnectionStatusType.connected;
    final state = this.state.copyWith(canConnect: canConnect);
    emit(state);
  }

  void joinRoom(String playerName) {
    if (roomRepository.isJoiningRoom || roomRepository.currentRoom != null) {
      return;
    }
    roomRepository.joinRoom(code: state.code, playerName: playerName);
  }

  void updateCode(String code) {
    final validCode = code.length == 6;
    emit(state.copyWith(validCode: validCode, code: code));
  }

  @override
  Future<void> close() async {
    await super.close();
    await _conSub.cancel();
  }
}
