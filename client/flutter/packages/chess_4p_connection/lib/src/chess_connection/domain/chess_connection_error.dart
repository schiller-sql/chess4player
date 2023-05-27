class ChessConnectionError implements Exception {
  final String uri;
  final int? closeCode;
  final String? closeReason;

  ChessConnectionError({
    required this.uri,
    this.closeCode,
    this.closeReason,
  });

  @override
  String toString() {
    var ret = "Connection to chess server failed at $uri";
    if(closeCode != null) {
      ", with close code: $closeCode";
    }
    if(closeReason != null) {
      ", with close reason: $closeReason";
    }
    return ret;
  }
}
