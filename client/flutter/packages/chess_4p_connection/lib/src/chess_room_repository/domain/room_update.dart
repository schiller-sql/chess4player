import 'room.dart';
import 'room_update_type.dart';

/// An update to the clients room
class RoomUpdate {
  /// The room that has been joined, left or force left from
  final ChessRoom chessRoom;

  /// What type of update, if the room has been joined, left or forced to leave
  final RoomUpdateType updateType;

  RoomUpdate({
    required this.chessRoom,
    required this.updateType,
  });
}
