part of 'in_room_cubit.dart';

@immutable
class InRoomState {
  final bool stillLoading;
  final ChessRoom room;

  const InRoomState({required this.stillLoading, required this.room});

  const InRoomState.initial()
      : stillLoading = false,
        room = const ChessRoom(code: '', playerName: '', isAdmin: false);

  @override
  String toString() {
    return 'InRoomState{stillLoading: $stillLoading, room: $room}';
  }
}
