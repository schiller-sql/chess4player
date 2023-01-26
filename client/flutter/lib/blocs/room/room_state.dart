part of 'room_cubit.dart';

@immutable
abstract class RoomState {
  const RoomState();
}

class RoomInitial extends RoomState {
  const RoomInitial();
}

class InRoom extends RoomState {
  final bool isAdmin;
  final ChessRoom room;

  const InRoom({required this.room, required this.isAdmin});
}

class NotInRoom extends RoomState {
  const NotInRoom();
}
