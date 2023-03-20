part of 'room_cubit.dart';

@immutable
abstract class RoomState {
  const RoomState();
}

class RoomInitial extends RoomState {
  const RoomInitial();
}

class InRoom extends RoomState {
  final ChessRoom room;

  const InRoom({required this.room});
}

class NotInRoom extends RoomState {
  const NotInRoom();
}
