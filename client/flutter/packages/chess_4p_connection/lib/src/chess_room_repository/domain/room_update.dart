
import 'room.dart';
import 'room_update_type.dart';

class RoomUpdate {
  /// The room that has been joined, left or force left from
  final ChessRoom chessRoom;
  final RoomUpdateType updateType;

  RoomUpdate({
    required this.chessRoom,
    required this.updateType,
  });
}