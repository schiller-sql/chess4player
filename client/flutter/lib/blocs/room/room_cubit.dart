import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  final IChessRoomRepository roomRepository;
  late final StreamSubscription _sub;

  RoomCubit({required this.roomRepository}) : super(const RoomInitial());

  void startListeningToRoom() {
    emit(const NotInRoom());
    _sub = roomRepository.roomUpdateStream.listen(_roomUpdate);
  }

  void leave() {
    roomRepository.leaveRoom();
  }

  void _roomUpdate(RoomUpdate update) {
    switch (update.updateType) {
      case RoomUpdateType.leave:
        emit(const NotInRoom());
        break;
      case RoomUpdateType.forceLeave:
        emit(const WasForcedOutOfRoom());
        break;
      case RoomUpdateType.join:
      case RoomUpdateType.joining:
        emit(
          const InRoom(),
        );
        break;
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _sub.cancel();
  }
}
