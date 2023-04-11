import 'package:chess_4p/chess_4p.dart';

class RawMove {
  final Field from, to;
  final PieceType? promotion;

  RawMove({
    required this.from,
    required this.to,
    required this.promotion,
  });

  factory RawMove.fromJson(Map<String, dynamic> json) {
    final rawPromotion = json["promotion"] as String?;
    final promotion =
        rawPromotion == null ? null : _promotionFromString(rawPromotion);
    final rawMoveData = json["move"] as List;
    final from = Field(rawMoveData[0], rawMoveData[1]);
    final to = Field(rawMoveData[2], rawMoveData[3]);
    return RawMove(from: from, to: to, promotion: promotion);
  }

  static PieceType _promotionFromString(String s) {
    switch (s) {
      case "q":
        return PieceType.queen;
      case "r":
        return PieceType.rook;
      case "n":
        return PieceType.knight;
      case "b":
        return PieceType.bishop;
    }
    throw ArgumentError("$s is not an acceptable promotion");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawMove &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          promotion == other.promotion;

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ promotion.hashCode;
}
