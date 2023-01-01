import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';

class ConnectionCubit extends Cubit<ConnectionStatus> {
  final IChessConnectionRepository connectionRepository;
  final IChessRoomRepository roomRepository;

  late final StreamSubscription _sub;

  ConnectionCubit({
    required this.roomRepository,
    required this.connectionRepository,
  }) : super(const ConnectionStatus.notConnected());

  void startConnection() {
    connectionRepository.connect();
    emit(connectionRepository.currentConnectionStatus);
    connectionRepository.connectionStatus.listen(_connectionStatusUpdate);
  }

  void retry() {
    connectionRepository.connect();
  }

  void _connectionStatusUpdate(ConnectionStatus status) {
    if(status.type == ConnectionStatusType.error) {
      roomRepository.resetCurrentRoom();
    }
    emit(status);
  }

  @override
  Future<void> close() async {
    await super.close();
    await _sub.cancel();
  }
}
