import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final IChessRoomRepository roomRepository;
  final IChessConnectionRepository connectionRepository;
  late final StreamSubscription _conSub;

  CreateRoomCubit({
    required this.roomRepository,
    required this.connectionRepository,
  }) : super(CreateRoomInitial());

  void startListeningToConnection() {
    _connectionStatusUpdate(connectionRepository.currentConnectionStatus);
    _conSub =
        connectionRepository.connectionStatus.listen(_connectionStatusUpdate);
  }

  void _connectionStatusUpdate(ConnectionStatus status) {
    emit(
      status.type == ConnectionStatusType.connected
          ? CanCreateRoom()
          : CannotCreateRoom(),
    );
  }

  void createRoom({required String playerName}) {
    if (roomRepository.isJoiningRoom || roomRepository.currentRoom != null) {
      return;
    }
    roomRepository.createRoom(playerName: playerName);
  }

  @override
  Future<void> close() async {
    await super.close();
    await _conSub.cancel();
  }
}
