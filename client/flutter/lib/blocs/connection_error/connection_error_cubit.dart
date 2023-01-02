import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chess_4p_connection/chess_4p_connection.dart';
import 'package:flutter/material.dart';

part 'connection_error_state.dart';

class ConnectionErrorCubit extends Cubit<ConnectionErrorState> {
  final IChessConnectionRepository connectionRepository;
  late final StreamSubscription _conSub;

  ConnectionErrorCubit({
    required this.connectionRepository,
  }) : super(const InitialConnectionError());

  void startListeningToConnection() {
    _connectionUpdate(connectionRepository.currentConnectionStatus);
    _conSub = connectionRepository.connectionStatus.listen(_connectionUpdate);
  }

  void _connectionUpdate(ConnectionStatus status) {
    if (status.type == ConnectionStatusType.error &&
        status.errorType == ConnectionErrorType.connectionInterrupt) {
      emit(ConnectionError(message: status.errorType.name));
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _conSub.cancel();
  }
}
