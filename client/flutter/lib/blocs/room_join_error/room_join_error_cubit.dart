import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:meta/meta.dart';

part 'room_join_error_state.dart';

class RoomJoinErrorCubit extends Cubit<RoomJoinErrorState> {
  final IChessRoomRepository roomRepository;
  late final StreamSubscription _sub;

  RoomJoinErrorCubit({required this.roomRepository,}) : super(RoomJoinErrorInitial());

  void startListeningToRoom() {
    _sub = roomRepository.roomUpdateStream.listen(null, onError: (error) {
      if(error is RoomJoinException) {
        emit(RoomJoinError(message: error.reason.message));
      }
    });
  }

  @override
  Future<void> close() async{
    await super.close();
    await _sub.cancel();
  }
}
