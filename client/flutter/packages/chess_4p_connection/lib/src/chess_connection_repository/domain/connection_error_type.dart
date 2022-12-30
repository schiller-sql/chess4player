enum ConnectionErrorType {
  couldNotConnect("could not connect"),
  connectionInterrupt("connection interrupt");

  final String _stringRep;

  const ConnectionErrorType(this._stringRep);

  @override
  String toString() {
    return _stringRep;
  }
}
