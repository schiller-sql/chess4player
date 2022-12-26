class RoomJoinException implements Exception {
  final String errorMessage;

  RoomJoinException(this.errorMessage);

  @override
  String toString() {
    return "Could not join room because: $errorMessage";
  }
}
