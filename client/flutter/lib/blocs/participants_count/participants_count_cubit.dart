import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';

class ParticipantsCountCubit extends Cubit<int> {
  final IChessRoomRepository roomRepository;
  late final StreamSubscription _sub;

  ParticipantsCountCubit({
    required this.roomRepository,
  }) : super(pow(2, 53).toInt());

  void startListeningToParticipants() {
    emit(roomRepository.currentRoomParticipantsCount);
    _sub = roomRepository.chessRoomParticipantsCount.listen((count) {
      emit(count);
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _sub.cancel();
  }
}
