import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'room_error_state.dart';

class RoomErrorCubit extends Cubit<RoomErrorState> {
  final IChessRoomRepository roomRepository;
  late final StreamSubscription _sub;

  RoomErrorCubit({required this.roomRepository,}) : super(RoomErrorInitial());

  void startListeningToRoom() {
    _sub = roomRepository.roomUpdateStream.listen(null, onError: (error) {
      if(error is RoomJoinException) {
        emit(CouldNotGetInRoomError(message: error.reason.message));
      }
      if(error is RoomDisbandedException) {
        emit(RoomDisbandedError());
      }
    });
  }

  @override
  Future<void> close() async{
    await super.close();
    await _sub.cancel();
  }
}
