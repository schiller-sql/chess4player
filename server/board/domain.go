package board

type Direction int

const (
	Up Direction = iota
	Right
	Down
	Left
)

func (d Direction) isVertical() bool {
	return d == Up || d == Down
}

func (d Direction) getVector() Vector {
	switch d {
	case Up:
		return Vector{0, -1}
	case Right:
		return Vector{1, 0}
	case Down:
		return Vector{0, 1}
	case Left:
		return Vector{-1, 0}
	}
	panic("Direction only has 4 values")
}

type PieceType int

const (
	Pawn PieceType = iota
	Rook
	Knight
	Bishop
	Queen
	King
)

func PieceTypeFromChar(char string) PieceType {
	switch char {
	case "n":
		return Knight
	case "r":
		return Rook
	case "b":
		return Bishop
	case "q":
		return Queen
	}
	panic("not possible to have another character than k, r, b, or q")
}

func (piece PieceType) String(white bool) string {
	if white {
		switch piece {
		case King:
			return "♔"
		case Queen:
			return "♕"
		case Rook:
			return "♖"
		case Bishop:
			return "♗"
		case Knight:
			return "♘"
		default:
			return "♙"
		}
	}
	switch piece {
	case King:
		return "♚"
	case Queen:
		return "♛"
	case Rook:
		return "♜"
	case Bishop:
		return "♝"
	case Knight:
		return "♞"
	default:
		return "♟︎"
	}
}

type Point struct {
	X, Y int
}

func (v Vector) neg() Vector {
	return Vector{Dx: -v.Dx, Dy: -v.Dy}
}

func (p Point) applyVector(v Vector) Point {
	p.X += v.Dx
	p.Y += v.Dy
	return p
}

type Vector struct {
	Dx, Dy int
}

func (v Vector) isDiagonal() bool {
	return v.Dx != 0 && v.Dy != 0
}

type Board struct {
	data      [14][14]*Piece // first index is Y, second index is X
	enPassant []*Piece       // TODO
}

func (b *Board) IsOut(direction Direction) {
	for y := 0; y < 14; y++ {
		for x := 0; x < 14; x++ {
			piece := b.data[y][x]
			if piece.Direction != direction {
				piece.Dead = true
			}
		}
	}
}

type Piece struct {
	Type      PieceType
	Direction Direction
	HasMoved  bool
	Dead      bool
}

func NewPiece(direction Direction, pieceType PieceType) *Piece {
	return &Piece{
		Direction: direction,
		Type:      pieceType,
	}
}

func (b *Board) String() string {
	s := ""
	for y := 0; y < 14; y++ {
		for x := 0; x < 14; x++ {
			piece := b.data[y][x]
			if piece == nil {
				s += " "
			} else {
				isWhite := piece.Direction == Up || piece.Direction == Down
				s += piece.Type.String(isWhite)
			}
			s += "  "
		}
		s += "\n"
	}
	return s
}

func (b *Board) Get(point Point) *Piece {
	if !b.IsInBoard(point) {
		panic("should be in board")
	}
	return b.data[point.Y][point.X]
}

func (b *Board) Set(point Point, piece *Piece) {
	if !b.IsInBoard(point) {
		panic("should be in board")
	}
	b.data[point.Y][point.X] = piece
}
