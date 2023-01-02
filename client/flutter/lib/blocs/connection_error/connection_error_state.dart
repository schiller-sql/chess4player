part of 'connection_error_cubit.dart';

@immutable
abstract class ConnectionErrorState {
  const ConnectionErrorState();
}

class InitialConnectionError extends ConnectionErrorState {
  const InitialConnectionError();
}

class ConnectionError extends ConnectionErrorState {
  final String message;

  const ConnectionError({required this.message});
}
