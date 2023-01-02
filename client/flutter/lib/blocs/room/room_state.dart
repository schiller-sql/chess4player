part of 'room_cubit.dart';

@immutable
abstract class RoomState {
  const RoomState();
}

class RoomInitial extends RoomState {
  const RoomInitial();
}

class InRoom extends RoomState {
  const InRoom();
}

class NotInRoom extends RoomState {
  const NotInRoom();
}
