package board

// TODO: insufficient-material check

// TODO: ineffizient: zum generieren werden unglaublich viele array reads und writes gemacht (14 x 14 x 4)
// TODO: optimalerweise sollte es nur 64 writes geben und keine reads
// TODO: außerdem werden extrem viele arrays verworfen
func (b *Board) GenerateBoard(generate [4]bool) {
	for i := 0; i < 4; i++ {
		var direction Direction
		switch i {
		case 0:
			{
				direction = Down
			}
		case 1:
			{
				direction = Right
			}
		case 2:
			{
				direction = Up
			}
		case 3:
			{
				direction = Left
			}
		}
		if generate[direction] {
			b.data[0] = [14]*Piece{
				nil, nil, nil,
				{Type: Rook, Direction: direction},
				{Type: Knight, Direction: direction},
				{Type: Bishop, Direction: direction},
				{Type: King, Direction: direction},
				{Type: Queen, Direction: direction},
				{Type: Bishop, Direction: direction},
				{Type: Knight, Direction: direction},
				{Type: Rook, Direction: direction},
				nil, nil, nil,
			}
			b.data[1] = [14]*Piece{
				nil, nil, nil,
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				{Type: Pawn, Direction: direction},
				nil, nil, nil,
			}
		}
		for j := 0; j < 6; j++ {
			for k := j; k < 13-j; k++ {
				temp := b.data[j][k]
				b.data[j][k] = b.data[13-k][j]
				b.data[13-k][j] = b.data[13-j][13-k]
				b.data[13-j][14-1-k] = b.data[k][13-j]
				b.data[k][13-j] = temp
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

func (b *Board) ValidMove(from, to Point, promotion *Piece, playerDirection Direction) bool {
	return true
}

/// if true, king cannot move
func (b *Board) checkIfKingCannotMove(kingPos Point, direction Direction) bool {
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

func (b *Board) checkIfPointInVector(vec Vector, vecP, p Point) bool {
	line := vecP
	for b.IsInBoard(line) {
		if line == p {
			return true
		}
		line = line.applyVector(vec)
	}
	return false
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

func (b *Board) posOkToAttack(pos Point, attackingDirection Direction) bool {
	return b.IsInBoard(pos) && (b.Get(pos) == nil || b.Get(pos).Direction != attackingDirection)
}

func (b *Board) straightPieceCanMove(piece *Piece, piecePos Point, lockingVectors map[Point]Vector, straight, diagonal bool) bool {
	var (
		inVector  bool
		foundVec  Vector
		foundVecP Point
	)
	for vecP, vec := range lockingVectors {
		if b.checkIfPointInVector(vec, vecP, piecePos) {
			inVector = true
			foundVec = vec
			foundVecP = vecP
			break
		}
	}
	for dy := -1; dy <= 1; dy++ {
		for dx := -1; dx <= 1; dx++ {
			if dy == 0 && dx == 0 {
				continue
			}
			addVec := Vector{dx, dy}
			if addVec.isDiagonal() && !diagonal {
				continue
			}
			if !addVec.isDiagonal() && !straight {
				continue
			}
			possiblePoint := piecePos.applyVector(addVec)
			if b.posOkToAttack(possiblePoint, piece.Direction) {
				if inVector {
					return b.checkIfPointInVector(foundVec, foundVecP, possiblePoint)
				} else {
					return true
				}
			}
		}
	}
	return false
}

func (b *Board) pieceCanMove(piece *Piece, piecePos Point, lockingVectors map[Point]Vector) bool {
	switch piece.Type {
	case King:
		panic("king should be already checked, as its checking should be done by the checkmate and remi algorithm")
	case Knight:
		for vecP, vec := range lockingVectors {
			if b.checkIfPointInVector(vec, vecP, piecePos) {
				return false
			}
		}
		for _switch := 0; _switch < 2; _switch++ {
			for longRange := -2; longRange <= 2; longRange += 4 {
				for shortRange := -1; shortRange <= 1; shortRange += 2 {
					dx := longRange
					dy := shortRange
					if _switch == 1 {
						dx, dy = dy, dx
					}
					possiblePos := piecePos.applyVector(Vector{Dx: dx, Dy: dy})
					if b.posOkToAttack(possiblePos, piece.Direction) {
						return true
					}
				}
			}
		}
		return false
	case Pawn:
		forward := piecePos.applyVector(piece.Direction.getVector())
		for vecP, vec := range lockingVectors {
			if b.checkIfPointInVector(vec, vecP, piecePos) {
				if canReach, _ := b.CanReach(piecePos, vecP, piece, true, Point{}); canReach {
					return true
				}
				if !b.IsInBoard(forward) {
					return false
				}
				if b.Get(forward) != nil {
					return false
				}
				return b.checkIfPointInVector(vec, vecP, forward)
			}
		}
		for i := -1; i <= 1; i++ {
			possiblePos := forward
			if piece.Direction.isVertical() {
				possiblePos.X += i
			} else {
				possiblePos.Y += i
			}
			if b.IsInBoard(possiblePos) && (b.Get(possiblePos) == nil) == (i == 0) {
				field := b.Get(possiblePos)
				if i == 0 {
					if field == nil {
						return true
					}
				} else {
					if field != nil && field.Direction != piece.Direction {
						return true
					}
				}
			}
		}
		return false
	case Queen:
		return b.straightPieceCanMove(piece, piecePos, lockingVectors, true, true)
	case Bishop:
		return b.straightPieceCanMove(piece, piecePos, lockingVectors, false, true)
	case Rook:
		return b.straightPieceCanMove(piece, piecePos, lockingVectors, true, false)
	}
	panic("cannot be any other piece")
}

func (b *Board) CheckEndForDirection(direction Direction) (checkmate, remi bool) {
	checkState, attacker, kingPos, attackingVec := b.AnalyzeCheck(direction)
	if checkState == NotCheck {
		if b.checkIfKingCannotMove(kingPos, direction) {
			locking, _ := b.GetCheckingVectors(direction, kingPos)
			// check for remi, because king cannot move, but is not in check
			for y := 0; y < 14; y++ {
				for x := 0; x < 14; x++ {
					piece := b.data[y][x]
					if piece != nil && piece.Direction == direction && piece.Type != King {
						if b.pieceCanMove(piece, Point{x, y}, locking) {
							return false, false
						}
					}
				}
			}
			return false, true
		}
		return false, false
	}
	if checkState == Check {
		// Check for save before king
		isAttacker := true
		p := attacker
	checkSave:
		for p != kingPos {
			for y := 0; y < 14; y++ {
				for x := 0; x < 14; x++ {
					savingPiece := b.data[y][x]
					savingPos := Point{x, y}
					if savingPiece != nil && savingPiece.Direction == direction && savingPos != kingPos {
						canReach, _ := b.CanReach(savingPos, p, savingPiece, isAttacker, Point{})
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
			isAttacker = false
		}
	}
	return b.checkIfKingCannotMove(kingPos, direction), false
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

func (b *Board) PlayerDead(direction Direction) {
	for y := 0; y < 14; y++ {
		for x := 0; x < 14; x++ {
			piece := b.data[y][x]
			if piece != nil && piece.Direction == direction {
				piece.Dead = true
			}
		}
	}
}

func (b *Board) Move(from, to Point, promotion *Piece) {
	movingPiece := b.data[from.Y][from.X]
	b.data[from.Y][from.X] = nil
	if promotion != nil {
		movingPiece = promotion
	}
	b.data[to.Y][to.X] = movingPiece
	// castle
	if movingPiece.Type == King {
		disX := to.X - from.X
		disY := to.Y - from.Y
		if abs(disX) != 2 && abs(disY) != 2 {
			return
		}
		vec := Vector{toOneOrZero(disX), toOneOrZero(disY)}
		rookPos := to.applyVector(vec)
		rookPiece := b.Get(rookPos)
		if rookPiece == nil {
			rookPos = rookPos.applyVector(vec)
			rookPiece = b.Get(rookPos)
		}
		newTowerPosition := to.applyVector(vec.neg())
		b.Set(rookPos, nil)
		b.Set(newTowerPosition, rookPiece)
	}
	// TODO: en passent
}
