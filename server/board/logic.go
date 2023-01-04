package board

func (b *Board) GenerateBoard(generate [4]bool) {
	for direction := 0; direction < 4; direction++ {
		if !generate[direction] {
			continue
		}
		b.data[0] = [14]*Piece{
			nil, nil, nil,
			{Type: Rook, Direction: Direction(direction)},
			{Type: Knight, Direction: Direction(direction)},
			{Type: Bishop, Direction: Direction(direction)},
			{Type: King, Direction: Direction(direction)},
			{Type: Queen, Direction: Direction(direction)},
			{Type: Bishop, Direction: Direction(direction)},
			{Type: Knight, Direction: Direction(direction)},
			{Type: Rook, Direction: Direction(direction)},
			nil, nil, nil,
		}
		b.data[1] = [14]*Piece{
			nil, nil, nil,
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			{Type: Pawn, Direction: Direction(direction)},
			nil, nil, nil,
		}
		for i := 0; i < 6; i++ {
			for j := i; j < 13-i; j++ {
				temp := b.data[i][j]
				b.data[i][j] = b.data[13-j][i]
				b.data[13-j][i] = b.data[13-i][13-j]
				b.data[13-i][14-1-j] = b.data[j][13-i]
				b.data[j][13-i] = temp
			}
		}
	}
}

func (b *Board) IsInBoard(p Point) bool {
	if p.X < 0 || p.Y < 0 || p.X >= 14 || p.Y >= 14 {
		return false
	}
	return (p.X >= 3 && p.X <= 10) || (p.Y >= 3 && p.Y <= 10)
}

func (b *Board) ValidMove(move [4]int, promotion string) bool {
	return true
}

func (b *Board) checkKingEscapePositions(kingPos Point, direction Direction) bool {
	for addY := -1; addY <= 1; addY++ {
	escapePositions:
		for addX := -1; addX <= 1; addX++ {
			if addY == 0 && addX == 0 {
				continue escapePositions
			}
			addVec := Vector{addX, addY}
			kingEscPos := kingPos.applyVector(addVec)
			if !b.IsInBoard(kingEscPos) {
				continue escapePositions
			}
			kingEscPiece := b.Get(kingEscPos)
			if kingEscPiece != nil && kingEscPiece.Direction == direction {
				continue escapePositions
			}
			for y := 0; y < 14; y++ {
				for x := 0; x < 14; x++ {
					piece := b.data[y][x]
					p := Point{x, y}
					if piece != nil && piece.Direction != direction && p != kingEscPos {
						pieceCanAttack, _ := b.CanReach(p, kingEscPos, piece, true, kingPos)
						if pieceCanAttack {
							continue escapePositions
						}
					}
				}
			}
			return false
		}
	}
	return true
}

func (b *Board) GetCheckingVectors(direction Direction, kingPos Point) (locking, direct map[Point]Vector) {
	locking = make(map[Point]Vector)
	direct = make(map[Point]Vector)
	for y := 0; y < 14; y++ {
	potentialVectors:
		for x := 0; x < 14; x++ {
			p := Point{x, y}
			piece := b.data[y][x]
			if piece != nil && !piece.Dead && piece.Direction != direction {
				vecStraight := piece.Type == Queen || piece.Type == Rook
				vecDiagonal := piece.Type == Queen || piece.Type == Bishop
				if !vecStraight && !vecDiagonal {
					continue potentialVectors
				}
				exists, vec := b._vectorFromDiff(p, kingPos, vecDiagonal, vecStraight)
				if !exists {
					continue potentialVectors
				}
				line := p.applyVector(vec)
				isLocked := false
				for b.IsInBoard(line) {
					pieceOnLine := b.Get(line)
					if pieceOnLine != nil {
						if pieceOnLine.Direction != direction {
							continue potentialVectors
						}
						if pieceOnLine.Type == King {
							if isLocked {
								locking[p] = vec
							} else {
								direct[p] = vec
							}
						} else {
							if isLocked {
								continue potentialVectors
							} else {
								isLocked = true
							}
						}
					}
					line = line.applyVector(vec)
				}
			}
		}
	}
	return
}

func (b *Board) CanMove() {

}

/// TODO: REMI
func (b *Board) CheckEndForDirection(direction Direction) (checkmate, remi bool) {
	checkState, attacker, kingPos, attackingVec := b.AnalyzeCheck(direction)
	if checkState == NotCheck {
		if !b.checkKingEscapePositions(kingPos, direction) {
			// check for remi, because king cannot move, but is not in check
			for y := 0; y < 14; y++ {
				for x := 0; x < 14; x++ {
					// TODO
				}
			}
		}
		return false, false
	}
	if checkState == Check {
		// Check for save before king
		p := attacker
	checkSave:
		for p != kingPos {
			for y := 0; y < 14; y++ {
				for x := 0; x < 14; x++ {
					savingPiece := b.data[y][x]
					savingPos := Point{x, y}
					if savingPiece != nil && savingPiece.Direction == direction && savingPos != kingPos {
						canReach, _ := b.CanReach(savingPos, p, savingPiece, false, Point{})
						if canReach {
							return false, false
						}
					}
				}
			}
			if attackingVec == nil {
				break checkSave
			}
			p = p.applyVector(*attackingVec)
		}
	}
	return b.checkKingEscapePositions(kingPos, direction), false
}

func abs(a int) int {
	if a < 0 {
		return -a
	}
	return a
}

/// a < 0  -> -1
/// a > 0  ->  1
/// a = 0  ->  0
func toOneOrZero(a int) int {
	if a > 0 {
		return 1
	} else if a < 0 {
		return -1
	}
	return 0
}

func (b *Board) _vectorFromDiff(from, to Point, diagonalAllowed bool, straightAllowed bool) (vectorExists bool, vector Vector) {
	diffX := to.X - from.X
	diffY := to.Y - from.Y
	// Check if it is possible for a vector to cross
	if abs(diffX) != abs(diffY) && diffX != 0 && diffY != 0 {
		return
	}
	// create the vector
	vec := Vector{Dx: toOneOrZero(diffX), Dy: toOneOrZero(diffY)}
	// Check if the vector is diagonal, but diagonal vectors are not allowed
	if !diagonalAllowed && vec.Dx != 0 && vec.Dy != 0 {
		return
	}
	// Check if the vector is straight, but straight vectors are not allowed
	if !straightAllowed && (vec.Dx == 0 || vec.Dy == 0) {
		return
	}
	return true, vec
}

func (b *Board) _canReachStraight(from, to Point, diagonalAllowed bool, straightAllowed bool, transparentPoint Point) (bool, *Vector) {
	exists, vec := b._vectorFromDiff(from, to, diagonalAllowed, straightAllowed)
	if !exists {
		return false, nil
	}
	// run the vector through and look if it hits anything else,
	// before the actual point
	p := from.applyVector(vec)
	for b.IsInBoard(p) {
		if p == to {
			return true, &vec
		}
		if p != transparentPoint && b.Get(p) != nil {
			return false, nil
		}
		p = p.applyVector(vec)
	}
	return false, nil
}

// CanReach the piece that is being reached for is not checked,
// only the one that is attacking is checked
func (b *Board) CanReach(from, to Point, fromPiece *Piece, attacking bool, transparentPoint Point) (bool, *Vector) {
	if fromPiece.Dead {
		return false, nil
	}
	switch fromPiece.Type {
	case King:
		disX := abs(from.X - to.X)
		disY := abs(from.Y - to.Y)
		return disX <= 1 && disY <= 1 && (disX == 1 || disY == 1), nil
	case Knight:
		disX := abs(from.X - to.X)
		disY := abs(from.Y - to.Y)
		return (disX == 1 || disX == 2) &&
			(disY == 1 || disY == 2) &&
			disX != disY, nil
	case Queen:
		return b._canReachStraight(from, to, true, true, transparentPoint)
	case Bishop:
		return b._canReachStraight(from, to, true, false, transparentPoint)
	case Rook:
		return b._canReachStraight(from, to, false, true, transparentPoint)
	case Pawn:
		if attacking {
			p := from.applyVector(fromPiece.Direction.getVector())
			if fromPiece.Direction.isVertical() {
				return p.applyVector(Vector{Dx: 1}) == to || p.applyVector(Vector{Dx: -1}) == to, nil
			} else {
				return p.applyVector(Vector{Dy: 1}) == to || p.applyVector(Vector{Dy: -1}) == to, nil
			}
		} else {
			p := from.applyVector(fromPiece.Direction.getVector())
			if p == to {
				return true, nil
			}
			if !fromPiece.HasMoved && b.Get(p) == nil {
				p = p.applyVector(fromPiece.Direction.getVector())
				return p == to, nil
			}
			return false, nil
		}
	}
	panic("should not be able to")
}

func (b *Board) kingPosition(direction Direction) Point {
	for y := 0; y < 14; y++ {
		for x := 0; x < 14; x++ {
			piece := b.data[y][x]
			if piece != nil && piece.Type == King && piece.Direction == direction {
				return Point{X: x, Y: y}
			}
		}
	}
	panic("ok")
}

type CheckState int

const (
	NotCheck CheckState = iota
	Check
	MultipleCheck
)

func (b *Board) AnalyzeCheck(direction Direction) (checkState CheckState, attacker, kingPos Point, vec *Vector) {
	kingPos = b.kingPosition(direction)
	for y := 0; y < 14; y++ {
		for x := 0; x < 14; x++ {
			piece := b.data[y][x]
			if piece != nil && piece.Direction != direction {
				p := Point{x, y}
				canAttack, nVec := b.CanReach(p, kingPos, piece, true, Point{})
				if canAttack {
					if checkState == Check {
						checkState = MultipleCheck
						return
					} else {
						checkState = Check
						attacker = p
						vec = nVec
					}
				}
			}
		}
	}
	return
}
