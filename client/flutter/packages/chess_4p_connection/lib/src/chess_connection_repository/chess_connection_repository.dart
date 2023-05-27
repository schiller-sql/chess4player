import 'dart:async';

import 'package:chess_4p_connection/src/chess_connection_repository/chess_connection_repository_contract.dart';
import 'package:chess_4p_connection/src/chess_connection_repository/domain/connection_error_type.dart';
import 'package:chess_4p_connection/src/chess_connection_repository/domain/connection_status.dart';
import 'package:chess_4p_connection/src/chess_connection_repository/domain/connection_status_type.dart';

import '../chess_connection/chess_connection.dart';

class ChessConnectionRepository implements IChessConnectionRepository {
  static const _waitTillLoadingFinishedDefault = Duration(milliseconds: 1000);

  final ChessConnection connection;
  final Duration waitTillLoadingFinished;

  ChessConnectionRepository({
    required this.connection,
    this.waitTillLoadingFinished = _waitTillLoadingFinishedDefault,
  });

  @override
  void connect({required String uri}) {
    assert(currentConnectionStatus.type != ConnectionStatusType.loading);

    _changeConnectionStatus(ConnectionStatus.loading());

    final loadingFinish = Future.delayed(waitTillLoadingFinished);
    final connectionFinish = connection.connect(uri: uri);
    var wasError = false;
    connectionFinish.then((_) {
      _changeConnectionStatus(ConnectionStatus.notConnected());
    }).catchError((error) {
      wasError = true;
      late final ConnectionErrorType errorType;
      if(currentConnectionStatus.type == ConnectionStatusType.loading) {
        errorType = ConnectionErrorType.couldNotConnect;
      } else {
        errorType = ConnectionErrorType.connectionInterrupt;
      }
      _changeConnectionStatus(ConnectionStatus.error(errorType));
    });
    loadingFinish.then((_) {
      if(wasError) return;
      _changeConnectionStatus(ConnectionStatus.connected());
    });
  }

  void _changeConnectionStatus(ConnectionStatus status) {
    connectionStatusController.add(status);
    currentConnectionStatus = status;
  }

  final connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  @override
  Stream<ConnectionStatus> get connectionStatus =>
      connectionStatusController.stream;

  @override
  ConnectionStatus currentConnectionStatus =
      const ConnectionStatus.notConnected();
}
