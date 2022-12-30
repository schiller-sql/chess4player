import 'package:chess_4p_connection/src/chess_connection_repository/domain/connection_error_type.dart';
import 'package:chess_4p_connection/src/chess_connection_repository/domain/connection_status_type.dart';

class ConnectionStatus {
  final ConnectionStatusType type;
  final ConnectionErrorType? _errorType;

  ConnectionErrorType get errorType => _errorType!;

  const ConnectionStatus._(this.type, this._errorType);

  const ConnectionStatus.loading() : this._(ConnectionStatusType.loading, null);

  const ConnectionStatus.error(ConnectionErrorType errorType)
      : this._(ConnectionStatusType.error, errorType);

  const ConnectionStatus.connected()
      : this._(ConnectionStatusType.connected, null);

  const ConnectionStatus.notConnected()
      : this._(ConnectionStatusType.notConnected, null);
}
