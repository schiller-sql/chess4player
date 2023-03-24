import '../domain/board.dart';
import '../domain/direction.dart';
import '../domain/field.dart';
import '../domain/piece.dart';
import '../domain/piece_type.dart';
import 'dart:math' as math;

import '../domain/readable_board.dart';

// TODO: en passent (first remove/but later pls)
// TODO: für alle analysis nach einem zug wird eine klassenobject erstellt

/// A vector on a chess board,
/// representing the possible straight and diagonal paths of
/// rooks, bishops and queens.
class _ChessVector {
  final int dx;
  final int dy;

  /// [dx] and [dy] can either be 0 or 1, but one of them needs to be 1,
  /// or else there would not be a vector.
  const _ChessVector(this.dx, this.dy)
      : assert(dx <= 1 && dx >= -1),
        assert(dy <= 1 && dy >= -1),
        assert(dx != 0 || dy != 0);
}

/// Analyzes a [Board] for all possible moves of a piece,
/// that has the direction of [analyzingDirection].
class BoardAnalyzer {
  /// The board to analyze.
  final ReadableBoard board;

  /// The direction to analyze from.
  final Direction analyzingDirection;

  /// Which [Board.changeIndex] the current cache is made for.
  int? _cachedBoardChangeIndex;

  /// Cached position of the king.
  late int _kingXCache;
  late int _kingYCache;

  /// Which pawns and knights are checking the king.
  final List<Field> _cachedCheckingPawnsAndKnights;

  /// From which fields a vector puts the king in check.
  ///
  /// This field can only contain bishop, rook, and queen.
  ///
  /// From a field max. one vector can hit the king,
  /// which is the reason for the [Map]
  final Map<Field, _ChessVector> _cachedCheckingVectors;

  /// From which fields a vector pins a piece.
  final Map<Field, _ChessVector> _cachedPinningVectors;

  /// Cached calls of [accessibleFields]
  final Map<Field, Set<Field>> _cachedAccessibleFields;

  bool get _isCheck =>
      _cachedCheckingPawnsAndKnights.isNotEmpty ||
      _cachedCheckingVectors.isNotEmpty;

  /// Default constructor, give [board] to analyze
  /// and which direction ([analyzingDirection])
  BoardAnalyzer({required this.board, required this.analyzingDirection})
      : _cachedCheckingPawnsAndKnights = [],
        _cachedCheckingVectors = {},
        _cachedPinningVectors = {},
        _cachedAccessibleFields = {};

  /// If a [_ChessVector] (param: [vector]) applied to [x] and [y],
  /// can reach [targetX] and [targetY], without before hitting [avoid]
  bool _liesInPath(
    _ChessVector vector,
    int x,
    int y,
    int targetX,
    int targetY,
    int avoidX,
    int avoidY,
  ) {
    do {
      if (targetX == x && targetY == y) {
        return true;
      }
      if (avoidX == x && avoidY == y) {
        return false;
      }
      x += vector.dx;
      y += vector.dy;
    } while (!board.isOut(x, y));
    return false;
  }

  /// If a piece at [x] and [y] is empty
  /// or if it is not the analyzed direction.
  bool _notOwnPiece(int x, int y) {
    return board.isEmpty(x, y) ||
        board.getPiece(x, y).direction != analyzingDirection;
  }

  /// If a piece at [x] and [y] is not empty
  /// and is the analyzed direction.
  bool _ownPiece(int x, int y) {
    return !_notOwnPiece(x, y);
  }

  /// Update [_kingXCache] and [_kingYCache],
  /// which give the location of the king.
  void _updateKingCache() {
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        if (board.isEmpty(x, y)) continue;
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

  /// Update [_cachedCheckingPawnsAndKnights], [_cachedCheckingVectors]
  /// and [_cachedPinningVectors] for information
  /// on how the king is checked and if pieces are pinned.
  void _updateCheckingPositions() {
    _cachedCheckingPawnsAndKnights.clear();
    _cachedCheckingVectors.clear();
    _cachedPinningVectors.clear();
    for (var y = 0; y < 14; y++) {
      for (var x = 0; x < 14; x++) {
        if (board.isEmpty(x, y)) continue;
        final piece = board.getPiece(x, y);
        if (piece.direction == analyzingDirection) continue;
        if (piece.isDead) continue;
        switch (piece.type) {
          case PieceType.pawn:
            if (_pawnCanAttack(
                x, y, piece.direction, _kingXCache, _kingYCache)) {
              _cachedCheckingPawnsAndKnights.add(Field(x, y));
            }
            break;
          case PieceType.knight:
            if (_knightCanReach(x, y, _kingXCache, _kingYCache)) {
              _cachedCheckingPawnsAndKnights.add(Field(x, y));
            }
            break;
          case PieceType.bishop:
            _analyzeVectorsFromPoint(x, y, checkDiagonal: true);
            break;
          case PieceType.rook:
            _analyzeVectorsFromPoint(x, y, checkStraight: true);
            break;
          case PieceType.queen:
            _analyzeVectorsFromPoint(x, y,
                checkDiagonal: true, checkStraight: true);
            break;
          case PieceType.king:
            // king cannot check
            break;
        }
      }
    }
  }

  /// Check if a chess vectors from the point [x] and [y] check the king
  /// or pin a piece; and cache these vectors in
  /// [_cachedCheckingVectors] and [_cachedPinningVectors].
  ///
  /// Use [checkDiagonal] to analyze diagonal vectors and
  /// [checkStraight] to analyze straight vectors.
  void _analyzeVectorsFromPoint(
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
        var hasHitOwnPiece = false;
        while (!board.isOut(tempX + dx, tempY + dy)) {
          tempX += dx;
          tempY += dy;
          if (!board.isEmpty(tempX, tempY)) {
            final piece = board.getPiece(tempX, tempY);
            if (piece.direction == analyzingDirection &&
                piece.type == PieceType.king) {
              final field = Field(x, y);
              final vector = _ChessVector(dx, dy);
              if (!hasHitOwnPiece) {
                // direct check
                _cachedCheckingVectors[field] = vector;
              } else {
                // indirect check
                _cachedPinningVectors[field] = vector;
              }
              continue vectors;
            } else if (piece.direction != analyzingDirection ||
                hasHitOwnPiece) {
              continue vectors;
            } else {
              hasHitOwnPiece = true;
            }
          }
        }
      }
    }
  }

  /// If the [piece] would be able to attack [attackingX] and [attackingY]
  /// from [x] and [y].
  ///
  /// It also ignores the king for vectors.
  bool _canAttackIgnoringOwnKing(
      int x, int y, Piece piece, int attackingX, int attackingY) {
    switch (piece.type) {
      case PieceType.king:
        return _kingCanReach(x, y, attackingX, attackingY);
      case PieceType.bishop:
        return _vectorsFromPointCanAttackIgnoringOwnKing(
            x, y, attackingX, attackingY,
            checkDiagonal: true);
      case PieceType.rook:
        return _vectorsFromPointCanAttackIgnoringOwnKing(
            x, y, attackingX, attackingY,
            checkStraight: true);
      case PieceType.queen:
        return _vectorsFromPointCanAttackIgnoringOwnKing(
            x, y, attackingX, attackingY,
            checkStraight: true, checkDiagonal: true);
      case PieceType.knight:
        return _knightCanReach(x, y, attackingX, attackingY);
      case PieceType.pawn:
        return _pawnCanAttack(x, y, piece.direction, attackingX, attackingY);
    }
  }

  /// If a king would be able to attack [attackingX] and [attackingY]
  /// from [x] and [y].
  bool _kingCanReach(int x, int y, int attackingX, int attackingY) {
    for (var i = 1; i >= -1; i--) {
      for (var j = 1; j >= -1; j--) {
        if (i == 0 && j == 0) continue;
        if (x + i == attackingX && y + j == attackingY) {
          return true;
        }
      }
    }
    return false;
  }

  /// If a piece is the king of the [analyzingDirection].
  bool _pieceIsOwnKing(Piece piece) {
    return piece.type == PieceType.king &&
        piece.direction == analyzingDirection;
  }

  /// Check if a chess vectors from the point [x] and [y]
  /// can reach [attackingX] and [attackingY].
  /// If the vectors reach the from the [analyzingDirection],
  /// without having reached the point,
  /// they will simply ignore the king and continue.
  ///
  /// Use [checkDiagonal] to analyze diagonal vectors and
  /// [checkStraight] to analyze straight vectors.
  bool _vectorsFromPointCanAttackIgnoringOwnKing(
    int x,
    int y,
    int attackingX,
    int attackingY, {
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
        while (!board.isOut(tempX + dx, tempY + dy)) {
          tempX += dx;
          tempY += dy;
          if (tempX == attackingX && tempY == attackingY) {
            return true;
          }
          if (!board.isEmpty(tempX, tempY) &&
              !_pieceIsOwnKing(board.getPiece(tempX, tempY))) {
            continue vectors;
          }
        }
      }
    }
    return false;
  }

  /// If a knight can reach [attackingX] and [attackingY]
  /// from [knightX] and [knightY]
  bool _knightCanReach(
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

  /// If a pawn with the direction [pawnDirection] can attack
  /// [attackingX] and [attackingY] from [pawnX] and [pawnY]
  ///
  /// This assumes that at [attackingX] and [attackingY],
  /// there is an enemy piece.
  bool _pawnCanAttack(
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

  /// Updates and removes all caches if they are old.
  void _updateCacheIfNecessary([bool force = false]) {
    if (force || _cachedBoardChangeIndex == board.changeIndex) return;

    _cachedAccessibleFields.clear();
    _cachedBoardChangeIndex = board.changeIndex;

    _updateKingCache();
    _updateCheckingPositions();
  }

  /// All valid fields a pawn can move to from [x] and [y],
  /// without taking checking into account.
  Set<Field> _allAccessibleFieldsFromPawn(int x, int y, Piece piece) {
    final accessibleFields = <Field>{};
    final direction = piece.direction;
    if (direction == Direction.down || direction == Direction.up) {
      y += direction.dy;
      for (var i = -1; i <= 1; i++) {
        final tempX = x + i;
        if (!board.isOut(tempX, y) &&
            (((i == 0) && board.isEmpty(tempX, y)) ||
                ((i != 0) &&
                    !board.isEmpty(tempX, y) &&
                    _notOwnPiece(tempX, y)))) {
          accessibleFields.add(Field(tempX, y));
        }
      }
    } else {
      x += direction.dx;
      for (var i = -1; i <= 1; i++) {
        final tempY = y + i;
        (i == 0) != _notOwnPiece(x, tempY);
        if (!board.isOut(x, tempY) &&
            (((i == 0) && board.isEmpty(x, tempY)) ||
                ((i != 0) &&
                    !board.isEmpty(x, tempY) &&
                    _notOwnPiece(x, tempY)))) {
          accessibleFields.add(Field(x, tempY));
        }
      }
    }
    // x and y is now the piece in front of the pawn

    // pawn move two forward
    if (board.isEmpty(x, y)) {
      y += direction.dy;
      x += direction.dx;
      if (!piece.hasBeenMoved && !board.isOut(x, y) && board.isEmpty(x, y)) {
        accessibleFields.add(Field(x, y));
      }
    }
    return accessibleFields;
  }

  /// All valid fields a knight can move to from [x] and [y],
  /// without taking checking into account.
  Set<Field> _allAccessibleFieldsFromKnight(int x, int y) {
    final accessibleFields = <Field>{};
    var onX = true;
    do {
      for (var longShift = 2; longShift >= -2; longShift -= 4) {
        for (var shortShift = 1; shortShift >= -1; shortShift -= 2) {
          var tempX = x;
          var tempY = y;
          if (onX) {
            tempX += longShift;
            tempY += shortShift;
          } else {
            tempX += shortShift;
            tempY += longShift;
          }
          if (!board.isOut(tempX, tempY) && _notOwnPiece(tempX, tempY)) {
            accessibleFields.add(Field(tempX, tempY));
          }
        }
      }
      onX = !onX;
    } while (!onX);
    return accessibleFields;
  }

  /// All valid fields a bishop can move to from [x] and [y],
  /// without taking checking into account.
  Set<Field> _allAccessibleFieldsFromBishop(int x, int y) {
    final accessibleFields = <Field>{};
    for (var dx = 1; dx >= -1; dx -= 2) {
      for (var dy = 1; dy >= -1; dy -= 2) {
        int tempX = x + dx;
        int tempY = y + dy;
        while (!board.isOut(tempX, tempY)) {
          if (_ownPiece(tempX, tempY)) break;
          accessibleFields.add(Field(tempX, tempY));
          if (!board.isEmpty(tempX, tempY)) break;
          tempX += dx;
          tempY += dy;
        }
      }
    }
    return accessibleFields;
  }

  /// All valid fields a rook can move to from [x] and [y],
  /// without taking checking into account.
  Set<Field> _allAccessibleFieldsFromRook(int x, int y) {
    final accessibleFields = <Field>{};
    for (var dx = 1; dx >= -1; dx -= 1) {
      for (var dy = 1; dy >= -1; dy -= 1) {
        if ((dx == 0) != (dy == 0)) {
          int tempX = x + dx;
          int tempY = y + dy;
          while (!board.isOut(tempX, tempY)) {
            if (_ownPiece(tempX, tempY)) break;
            accessibleFields.add(Field(tempX, tempY));
            if (!board.isEmpty(tempX, tempY)) break;
            tempX += dx;
            tempY += dy;
          }
        }
      }
    }
    return accessibleFields;
  }

  /// All valid fields a rook can move to from [x] and [y],
  /// without taking checking into account.
  Set<Field> _allAccessibleFieldsFromQueen(int x, int y) {
    return _allAccessibleFieldsFromBishop(x, y)
      ..addAll(_allAccessibleFieldsFromRook(x, y));
  }

  /// All valid fields a king can move to from [x] and [y],
  /// without taking checking into account.
  Set<Field> _allAccessibleFieldsFromKing(int x, int y) {
    final accessibleFields = <Field>{};
    for (var i = 1; i >= -1; i--) {
      for (var j = 1; j >= -1; j--) {
        if (i == 0 && j == 0) continue;
        final tempX = x + i;
        final tempY = y + j;
        if (!board.isOut(tempX, tempY) && _notOwnPiece(tempX, tempY)) {
          accessibleFields.add(Field(tempX, tempY));
        }
      }
    }
    return accessibleFields;
  }

  /// the smallest non-diagonal distance between two points in chess
  int _smallestDistance(int x1, int y1, int x2, int y2) {
    // TODO: test
    return math.min((x1 - x2).abs(), (y1 - y2).abs());
  }

  /// Get a [Piece] (or null if empty) for a point at [x] and [y].
  /// However the coordinates are rotated
  /// according to the [analyzingDirection.clockwiseRotationsFromUp].
  Piece? _getPieceInRotationToAnalyzingDirection(int x, int y) {
    final rotatedX = Field.clockwiseRotateXBy(
        x, y, analyzingDirection.clockwiseRotationsFromUp);
    final rotatedY = Field.clockwiseRotateYBy(
        x, y, analyzingDirection.clockwiseRotationsFromUp);
    if (board.isEmpty(rotatedX, rotatedY)) {
      return null;
    }
    return board.getPiece(rotatedX, rotatedY);
  }

  bool _canAnyEnemyAttackIgnoringOwnKingInRotationToAnalyzingDirection(
    int attackingX,
    int attackingY,
  ) {
    // rotate
    final rotatedX = Field.clockwiseRotateXBy(
        attackingX, attackingY, analyzingDirection.clockwiseRotationsFromUp);
    attackingY = Field.clockwiseRotateYBy(
        attackingX, attackingY, analyzingDirection.clockwiseRotationsFromUp);
    attackingX = rotatedX;
    for (int y = 0; y < 14; y++) {
      fields:
      for (int x = 0; x < 14; x++) {
        if (board.isOut(x, y) || board.isEmpty(x, y)) continue fields;
        final piece = board.getPiece(x, y);
        if (piece.direction == analyzingDirection) continue fields;
        if (piece.isDead) continue fields;
        if (_canAttackIgnoringOwnKing(x, y, piece, attackingX, attackingY)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Adds [Field]s to [set] if the king at [x] and [y] can castle,
  /// to his left and/or right side.
  ///
  /// From Wikipedia:
  /// Castling is permitted only if neither the king nor the rook has previously moved;
  /// the squares between the king and the rook are vacant; and the king does not leave,
  /// cross over, or end up on a square attacked by an opposing piece
  void _addCastleFieldsFromKingToSet(Piece kingPiece, Set<Field> set) {
    assert(kingPiece.type == PieceType.king);

    // TODO: not all fields have to be checked, as they are checked in _filteredAccessibleFieldsFromKing
    final king = _getPieceInRotationToAnalyzingDirection(7, 13);
    if (kingPiece != king) return;
    if (king!.hasBeenMoved) return;
    if (_isCheck) return;

    final leftRook = _getPieceInRotationToAnalyzingDirection(3, 13);
    final leftEmpty1 = _getPieceInRotationToAnalyzingDirection(4, 13);
    final leftEmpty2 = _getPieceInRotationToAnalyzingDirection(5, 13);
    final leftEmpty3 = _getPieceInRotationToAnalyzingDirection(6, 13);

    if (leftRook?.type == PieceType.rook &&
        leftRook?.hasBeenMoved == false &&
        leftEmpty1 == null &&
        leftEmpty2 == null &&
        leftEmpty3 == null &&
        !_canAnyEnemyAttackIgnoringOwnKingInRotationToAnalyzingDirection(
            5, 13) &&
        !_canAnyEnemyAttackIgnoringOwnKingInRotationToAnalyzingDirection(
            6, 13)) {
      set.add(Field.rotatedClockwise(
          5, 13, analyzingDirection.clockwiseRotationsFromUp));
    }

    final rightEmpty1 = _getPieceInRotationToAnalyzingDirection(8, 13);
    final rightEmpty2 = _getPieceInRotationToAnalyzingDirection(9, 13);
    final rightRook = _getPieceInRotationToAnalyzingDirection(10, 13);
    if (rightRook?.type == PieceType.rook &&
        rightRook?.hasBeenMoved == false &&
        rightEmpty1 == null &&
        rightEmpty2 == null &&
        !_canAnyEnemyAttackIgnoringOwnKingInRotationToAnalyzingDirection(
            8, 13) &&
        !_canAnyEnemyAttackIgnoringOwnKingInRotationToAnalyzingDirection(
            9, 13)) {
      set.add(Field.rotatedClockwise(
          9, 13, analyzingDirection.clockwiseRotationsFromUp));
    }
  }

  /// All valid fields the king can move to from [kingX] and [kingY],
  /// taking checking and castling into account.
  ///
  /// The field given for castling
  /// is the field on which the king stands after the castle.
  Set<Field> _filteredAccessibleFieldsFromKing(
      int kingX, int kingY, Piece piece) {
    final accessibleFields = _allAccessibleFieldsFromKing(kingX, kingY);
    for (var y = 0; y < 14; y++) {
      fields:
      for (var x = 0; x < 14; x++) {
        if (board.isOut(x, y)) continue fields;
        if (board.isEmpty(x, y)) continue fields;
        final piece = board.getPiece(x, y);
        if (piece.direction == analyzingDirection) continue fields;
        if (piece.isDead) continue fields;
        if (piece.type == PieceType.king || piece.type == PieceType.pawn) {
          if (_smallestDistance(kingX, kingY, x, y) > 2) continue fields;
        }
        accessibleFields.retainWhere((field) =>
            !_canAttackIgnoringOwnKing(x, y, piece, field.x, field.y));
      }
    }
    final kingPiece = board.getPiece(kingX, kingY);
    _addCastleFieldsFromKingToSet(kingPiece, accessibleFields);
    return accessibleFields;
  }

  /// All valid fields a non king piece can move to from [x] and [y],
  /// taking checking into account.
  Set<Field> _filteredAccessibleFieldsNonKing(int x, int y, Piece piece) {
    if(_cachedCheckingPawnsAndKnights.length > 1) {
      return const {};
    }
    late final Set<Field> accessibleFields;
    switch (piece.type) {
      case PieceType.pawn:
        accessibleFields = _allAccessibleFieldsFromPawn(x, y, piece);
        break;
      case PieceType.knight:
        accessibleFields = _allAccessibleFieldsFromKnight(x, y);
        break;
      case PieceType.bishop:
        accessibleFields = _allAccessibleFieldsFromBishop(x, y);
        break;
      case PieceType.rook:
        accessibleFields = _allAccessibleFieldsFromRook(x, y);
        break;
      case PieceType.queen:
        accessibleFields = _allAccessibleFieldsFromQueen(x, y);
        break;
      case PieceType.king:
        break;
    }
    if(_cachedCheckingPawnsAndKnights.length == 1) {
      if(accessibleFields.contains(_cachedCheckingPawnsAndKnights[0])) {
        return {_cachedCheckingPawnsAndKnights[0]};
      } else {
        return const {};
      }
    }
    _cachedPinningVectors.forEach((checkingPieceField, vector) {
      if (_liesInPath(
        vector,
        checkingPieceField.x,
        checkingPieceField.y,
        x,
        y,
        _kingXCache,
        _kingYCache,
      )) {
        accessibleFields.retainWhere(
          (field) => _liesInPath(
            vector,
            checkingPieceField.x,
            checkingPieceField.y,
            field.x,
            field.y,
            _kingXCache,
            _kingYCache,
          ),
        );
      }
    });
    _cachedCheckingVectors.forEach((checkingPieceField, vector) {
      accessibleFields.retainWhere(
        (field) => _liesInPath(
          vector,
          checkingPieceField.x,
          checkingPieceField.y,
          field.x,
          field.y,
          _kingXCache,
          _kingYCache,
        ),
      );
    });
    return accessibleFields;
  }

  /// All valid fields the piece at [x] and [y] can move to,
  /// taking checking and castling into account.
  ///
  /// Will cache most of its analyzing
  /// and the direct result in [_cachedAccessibleFields].
  Set<Field> accessibleFields(int x, int y) {
    // update or delete cache if necessary
    _updateCacheIfNecessary();
    final field = Field(x, y);
    // check if exact field has already been analysed
    final cachedAccessibleFields = _cachedAccessibleFields[field];
    if (cachedAccessibleFields != null) {
      return cachedAccessibleFields;
    }
    final piece = board.getPiece(x, y);
    assert(piece.direction == analyzingDirection);
    late final Set<Field> accessibleFields;
    if (piece.type == PieceType.king) {
      accessibleFields = _filteredAccessibleFieldsFromKing(x, y, piece);
    } else {
      accessibleFields = _filteredAccessibleFieldsNonKing(x, y, piece);
    }
    _cachedAccessibleFields[field] = accessibleFields;
    return accessibleFields;
  }

  /// If a field is analyzable;
  /// if a piece of the [analyzingDirection] is on this field.
  bool canAnalyze(int x, int y) {
    return !board.isEmpty(x, y) &&
        board.getPiece(x, y).direction == analyzingDirection;
  }

  /// if the king piece of the [analyzingDirection] is in check
  bool isKingInCheck() {
    _updateCacheIfNecessary();
    return _isCheck;
  }
}
