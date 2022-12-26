import 'package:chess_4p_connection/src/chess_room_repository/domain/room_join_error_reason.dart';

/// A room could not be joined and why
class RoomJoinException implements Exception {
  final RoomJoinErrorReason reason;

  RoomJoinException.fromErrorMessage(String errorMessage)
      : reason = RoomJoinErrorReason.fromString(errorMessage);

  @override
  String toString() {
    return "Could not join room because: $reason";
  }
}
