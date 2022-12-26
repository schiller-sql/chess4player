abstract class ChessConnectionListener {
  void createdRoom(String code, String name) {}

  void joinedRoom(String name) {}

  void leftRoom(bool wasForced) {}

  void participantsCountUpdate(int count) {}

  void joinError(String error) {}
}
