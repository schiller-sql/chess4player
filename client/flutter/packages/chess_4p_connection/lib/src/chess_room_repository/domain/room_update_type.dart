/// The type of update to a room
enum RoomUpdateType {
  /// The room is being joined
  joining,

  /// The room has been left by the client
  leave,

  /// The client has joined
  join,
}
