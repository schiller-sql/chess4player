import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'in_room_state.dart';

class InRoomCubit extends Cubit<InRoomState> {
  final IChessRoomRepository roomRepository;
  late final StreamSubscription _sub;

  InRoomCubit({required this.roomRepository})
      : super(const InRoomState.initial());

  void startListeningToRoom() {
    if (roomRepository.currentRoom != null) {
      emit(
        InRoomState(
          stillLoading: roomRepository.isJoiningRoom,
          room: roomRepository.currentRoom!,
        ),
      );
    }
    _sub = roomRepository.roomUpdateStream.listen(_roomUpdate, onError: (_) {});
  }

  void _roomUpdate(RoomUpdate update) {
    emit(
      InRoomState(
        stillLoading: update.updateType == RoomUpdateType.joining,
        room: update.chessRoom,
      ),
    );
  }

  @override
  Future<void> close() async {
    await super.close();
    await _sub.cancel();
  }
}
