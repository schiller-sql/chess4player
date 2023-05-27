import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';

import '../../repositories/connection_uri/connection_uri_repository.dart';

class ConnectionCubit extends Cubit<ConnectionStatus> {
  final IChessConnectionRepository connectionRepository;
  final IChessRoomRepository roomRepository;
  final ConnectionUriRepository connectionUriRepository;

  late final StreamSubscription _sub;

  ConnectionCubit({
    required this.roomRepository,
    required this.connectionRepository,
    required this.connectionUriRepository,
  }) : super(const ConnectionStatus.notConnected());

  void startConnection() {
    connectionRepository.connect(uri: connectionUriRepository.currentUri);
    emit(connectionRepository.currentConnectionStatus);
    connectionRepository.connectionStatus.listen(_connectionStatusUpdate);
  }

  void changeConnectionUri(String newUri) {
    connectionUriRepository.currentUri = newUri;
  }

  void retry() {
    connectionRepository.connect(uri: connectionUriRepository.currentUri);
  }

  void _connectionStatusUpdate(ConnectionStatus status) {
    if (status.type == ConnectionStatusType.error) {
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
