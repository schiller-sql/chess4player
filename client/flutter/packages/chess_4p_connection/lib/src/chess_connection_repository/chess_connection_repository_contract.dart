import 'domain/connection_status.dart';

abstract class IChessConnectionRepository {
  ConnectionStatus get currentConnectionStatus;
  Stream<ConnectionStatus> get connectionStatus;

  void connect({required String uri});
}