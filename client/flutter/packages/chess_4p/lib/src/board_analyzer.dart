import 'board/board.dart';
import 'direction.dart';
import 'field.dart';
import 'pieces/piece.dart';
import 'pieces/piece_type.dart';

class _ChessVector {
  final int dx;
  final int dy;

  const _ChessVector(this.dx, this.dy)
      : assert(dx <= 1 && dx >= -1),
        assert(dy <= 1 && dy >= -1);
}

class BoardAnalyzer {
  /// The board to analyze
  final Board board;

  /// The direction to analyze
  final Direction analyzingDirection;

  late int _cachedBoardChangeIndex;
  late int _kingXCache;
  late int _kingYCache;

  final List<Field> _cachedCheckingPawnsAndKnights;
  final Map<Field, _ChessVector> _cachedCheckingVectors;
  final Map<Field, _ChessVector> _cachedIndirectCheckingVectors;

  final Map<Field, Set<Field>> _cachedAccessibleFields;

  bool get isCheck =>
      _cachedCheckingPawnsAndKnights.isNotEmpty &&
      _cachedCheckingVectors.isNotEmpty &&
      _cachedAccessibleFields.isNotEmpty;

  BoardAnalyzer({required this.board, required this.analyzingDirection})
      : _cachedCheckingPawnsAndKnights = [],
        _cachedCheckingVectors = {},
        _cachedIndirectCheckingVectors = {},
        _cachedAccessibleFields = {} {
    _updateKingCache();
  }

  bool _liesInPath(
      _ChessVector vector, int x, int y, int targetX, int targetY) {
    do {
      if (targetX == x && targetY == y) {
        return true;
      }
      x += vector.dx;
      y += vector.dy;
    } while (!board.isOut(x, y));
    return false;
  }

  bool notOwnPiece(int x, int y) {
    return board.isEmpty(x, y) ||
        board.getPiece(x, y).direction != analyzingDirection;
  }

  void _updateKingCache() {
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        final p = board.getPiece(x, y);
        if (p.direction == analyzingDirection && p.type == PieceType.king) {
          _kingXCache = x;
          _kingYCache = y;
          return;
        }
      }
    }
    throw StateError(
        "King with direction '$analyzingDirection' does not exist");
  }

  void _updateCheckingPositions() {
    _cachedCheckingPawnsAndKnights.clear();
    _cachedCheckingVectors.clear();
    _cachedIndirectCheckingVectors.clear();
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        if (board.isEmpty(x, y)) continue;
        final piece = board.getPiece(x, y);
        if (piece.direction != analyzingDirection) continue;
        switch (piece.type) {
          case PieceType.pawn:
            if (pawnCanAttack(
                x, y, piece.direction, _kingXCache, _kingYCache)) {
              _cachedCheckingPawnsAndKnights.add(Field(x, y));
            }
            break;
          case PieceType.knight:
            if (knightCanReach(x, y, _kingXCache, _kingYCache)) {
              _cachedCheckingPawnsAndKnights.add(Field(x, y));
            }
            break;
          case PieceType.bishop:
            checkVector(x, y, checkDiagonal: true);
            break;
          case PieceType.rook:
            checkVector(x, y, checkStraight: true);
            break;
          case PieceType.queen:
            checkVector(x, y, checkDiagonal: true, checkStraight: true);
            break;
          case PieceType.king:
            // king cannot check
            break;
        }
      }
    }
  }

  void checkVector(
    int x,
    int y, {
    bool checkDiagonal = false,
    bool checkStraight = false,
  }) {
    assert(checkDiagonal || checkStraight);
    for (var dx = -1; dx <= 1; dx++) {
      vectors:
      for (var dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue vectors;
        final vectorIsStraight = dx == 0 || dy == 0;
        if (!checkStraight && vectorIsStraight) continue vectors;
        if (!checkDiagonal && !vectorIsStraight) continue vectors;

        var tempX = x;
        var tempY = y;
        var hasHitOwnPiece = true;
        do {
          tempX += dx;
          tempY += dy;
          if (!board.isEmpty(tempY, tempY)) {
            final piece = board.getPiece(tempX, tempY);
            if (piece.direction != analyzingDirection || hasHitOwnPiece) {
              continue vectors;
            } else if (piece.type == PieceType.king) {
              final field = Field(x, y);
              final vector = _ChessVector(dx, dy);
              if (!hasHitOwnPiece) {
                // direct check
                _cachedCheckingVectors[field] = vector;
              } else {
                // indirect check
                _cachedIndirectCheckingVectors[field] = vector;
              }
              continue vectors;
            } else {
              hasHitOwnPiece = true;
            }
          }
        } while (!board.isOut(tempX + dx, tempY + dy));
      }
    }
  }

  bool knightCanReach(
    int knightX,
    int knightY,
    int attackingX,
    int attackingY,
  ) {
    final xDistance = (knightX - attackingX).abs();
    final yDistance = (knightY - attackingY).abs();
    return (xDistance == 1 || xDistance == 2) &&
        (yDistance == 1 || yDistance == 2) &&
        xDistance != yDistance;
  }

  bool pawnCanAttack(
    int pawnX,
    int pawnY,
    Direction pawnDirection,
    int attackingX,
    int attackingY,
  ) {
    switch (pawnDirection) {
      case Direction.up:
        return pawnY - 1 == attackingY && (pawnX - attackingX).abs() == 1;
      case Direction.down:
        return pawnY + 1 == attackingY && (pawnX - attackingX).abs() == 1;
      case Direction.left:
        return pawnX - 1 == attackingX && (pawnY - attackingY).abs() == 1;
      default:
        return pawnX + 1 == attackingX && (pawnY - attackingY).abs() == 1;
    }
  }

  void _updateCacheIfNecessary([bool force = false]) {
    if (force || _cachedBoardChangeIndex == board.changeIndex) return;

    _cachedAccessibleFields.clear();
    _cachedBoardChangeIndex = board.changeIndex;

    _updateKingCache();
    _updateCheckingPositions();
  }

  Set<Field> allAccessibleFieldsFromPawn(int x, int y, Direction direction) {
    final accessibleFields = <Field>{};
    if (direction == Direction.down || direction == Direction.up) {
      y += direction.dy;
      for (var i = -1; i <= 1; i++) {
        final tempX = x + i;
        if (!board.isOut(tempX, y) && (i == 0) != notOwnPiece(tempX, y)) {
          accessibleFields.add(Field(tempX, y));
        }
      }
    } else {
      x += direction.dx;
      for (var i = -1; i <= 1; i++) {
        final tempY = y + i;
        if (!board.isOut(x, tempY) && (i == 0) != notOwnPiece(x, tempY)) {
          accessibleFields.add(Field(x, tempY));
        }
      }
    }
    return accessibleFields;
  }

  Set<Field> allAccessibleFieldsFromKnight(int x, int y) {
    final accessibleFields = <Field>{};
    var onX = true;
    do {
      for (var longShift = 2; longShift >= -2; longShift -= 4) {
        for (var shortShift = 1; longShift >= -1; longShift -= 2) {
          var tempX = x;
          var tempY = y;
          if (onX) {
            tempX += longShift;
            tempY += shortShift;
          } else {
            tempX += shortShift;
            tempY += longShift;
          }
          if (board.isOut(x, y) && notOwnPiece(x, y)) {
            accessibleFields.add(Field(tempX, tempY));
          }
        }
      }
      onX = !onX;
    } while (!onX);
    return accessibleFields;
  }

  Set<Field> allAccessibleFieldsFromBishop(int x, int y) {
    
    for(var dx = 1; dx >= -1; dx--) {
      for(var dy = 1; dy >= -1; dy--) {

      }
    }
  }

  Set<Field> allAccessibleFieldsFromRook(int x, int y) {
    throw UnimplementedError();
  }

  Set<Field> allAccessibleFieldsFromQueen(int x, int y) {
    return allAccessibleFieldsFromBishop(x, y)
      ..addAll(allAccessibleFieldsFromRook(x, y));
  }

  Set<Field> accessibleFieldsFromKing(int x, int y) {
    // TODO: cache
    throw UnimplementedError();
  }

  Set<Field> accessibleFieldsNonKing(int x, int y, Piece piece) {
    late final Set<Field> accessibleFields;
    if (_cachedCheckingPawnsAndKnights.isNotEmpty) {
      if (_cachedCheckingPawnsAndKnights.length > 1) {
        return {};
      } else {
        return {..._cachedCheckingPawnsAndKnights};
      }
    }
    switch (piece.type) {
      case PieceType.pawn:
        accessibleFields = allAccessibleFieldsFromPawn(x, y, piece.direction);
        break;
      case PieceType.knight:
        accessibleFields = allAccessibleFieldsFromKnight(x, y);
        break;
      case PieceType.bishop:
        accessibleFields = allAccessibleFieldsFromBishop(x, y);
        break;
      case PieceType.rook:
        accessibleFields = allAccessibleFieldsFromRook(x, y);
        break;
      case PieceType.queen:
        accessibleFields = allAccessibleFieldsFromQueen(x, y);
        break;
      case PieceType.king:
        break;
    }
    _cachedIndirectCheckingVectors.forEach((checkingPieceField, vector) {
      if (_liesInPath(
          vector, checkingPieceField.x, checkingPieceField.y, x, y)) {
        accessibleFields.retainWhere((field) => _liesInPath(vector,
            checkingPieceField.x, checkingPieceField.y, field.x, field.y));
      }
    });
    _cachedCheckingVectors.forEach((checkingPieceField, vector) {
      accessibleFields.retainWhere((field) => _liesInPath(vector,
          checkingPieceField.x, checkingPieceField.y, field.x, field.y));
    });
    return accessibleFields;
  }

  Set<Field> accessibleFields(int x, int y) {
    _updateCacheIfNecessary();
    final field = Field(x, y);
    final cachedAccessibleFields = _cachedAccessibleFields[field];
    if (cachedAccessibleFields != null) {
      return cachedAccessibleFields;
    }
    late final Set<Field> accessibleFields;
    final piece = board.getPiece(x, y);
    if (piece.type == PieceType.king) {
      accessibleFields = accessibleFieldsFromKing(x, y);
    } else {
      accessibleFields = accessibleFieldsNonKing(x, y, piece);
    }
    _cachedAccessibleFields[field] = accessibleFields;
    return accessibleFields;
  }
}
