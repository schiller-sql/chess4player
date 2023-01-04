package board_test

import (
	"github.com/stretchr/testify/require"
	"server/board"
	"testing"
)

func TestBoard(t *testing.T) {
	b := board.Board{}
	f := [4]bool{true, true, true, true}
	b.GenerateBoard(f)
	print(b.String())
	if b.IsInBoard(board.Point{Y: 14}) {
		t.Errorf("0|14 is not in board")
	}
	if !b.IsInBoard(board.Point{X: 8, Y: 8}) {
		t.Error()
	}
}

func TestCheckMateThreeRooks(t *testing.T) {
	b := board.Board{}
	b.Set(board.Point{Y: 4}, &board.Piece{Direction: board.Up, Type: board.Rook})
	b.Set(board.Point{Y: 5}, &board.Piece{Direction: board.Up, Type: board.Rook})
	b.Set(board.Point{Y: 6}, &board.Piece{Direction: board.Up, Type: board.Rook})

	b.Set(board.Point{X: 5, Y: 5}, &board.Piece{Direction: board.Down, Type: board.King})

	if checkMate, remi := b.CheckEndForDirection(board.Down); !checkMate && !remi {
		t.Error()
	}

	// rook that can save king
	b.Set(board.Point{X: 4, Y: 3}, &board.Piece{Direction: board.Down, Type: board.Rook})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate && !remi {
		t.Error()
	}
}

func TestCheckNotCheck(t *testing.T) {
	b := board.Board{}

	testCheck := func() {
		check, _, _, _ := b.AnalyzeCheck(board.Down)
		if check == board.Check || check == board.MultipleCheck {
			t.Error()
		}
	}

	b.Set(board.Point{X: 5, Y: 5}, &board.Piece{Direction: board.Down, Type: board.King})
	testCheck()

	b.Set(board.Point{X: 6, Y: 7}, &board.Piece{Direction: board.Up, Type: board.Queen})
	testCheck()

	b.Set(board.Point{X: 7, Y: 5}, &board.Piece{Direction: board.Up, Type: board.Queen})
	b.Set(board.Point{X: 6, Y: 5}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	testCheck()

	b.Set(board.Point{X: 7, Y: 5}, &board.Piece{Direction: board.Up, Type: board.Queen})
	b.Set(board.Point{X: 6, Y: 5}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	testCheck()
}

func TestCheckMateComplex(t *testing.T) {
	b := board.Board{}
	// king to be checkmated
	b.Set(board.Point{X: 5, Y: 5}, &board.Piece{Direction: board.Down, Type: board.King})

	// queen attacking from diagonal (touching king)
	b.Set(board.Point{X: 4, Y: 4}, &board.Piece{Direction: board.Up, Type: board.Queen})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate && !remi {
		t.Error()
	}

	// pawn attacking one escape
	b.Set(board.Point{X: 6, Y: 7}, &board.Piece{Direction: board.Up, Type: board.Pawn})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate && !remi {
		t.Error()
	}

	// pawn attacking other escape
	b.Set(board.Point{X: 7, Y: 4}, &board.Piece{Direction: board.Left, Type: board.Pawn})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate && !remi { // queen still attackable
		t.Error()
	}

	// protect queen with knight, now queen is not attackable
	b.Set(board.Point{X: 3, Y: 2}, &board.Piece{Direction: board.Left, Type: board.Knight})

	// is checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Down); !checkMate && !remi {
		t.Error()
	}

	// pawn +1 under queen protects the space +2 under the queen
	b.Set(board.Point{X: 4, Y: 5}, &board.Piece{Direction: board.Left, Type: board.Pawn})

	// king can go to this position
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate && !remi {
		t.Error()
	}

	// block this position with own piece
	b.Set(board.Point{X: 4, Y: 6}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	// checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Down); !checkMate && !remi {
		t.Error()
	}
}

func TestBoard_GetCheckingVectors(t *testing.T) {
	b := board.Board{}

	b.Set(board.Point{X: 5, Y: 5}, &board.Piece{Direction: board.Down, Type: board.King})

	// directly attacking rook
	b.Set(board.Point{X: 8, Y: 5}, &board.Piece{Direction: board.Up, Type: board.Rook})

	// attacking queen defended by pawn
	b.Set(board.Point{X: 10, Y: 10}, &board.Piece{Direction: board.Up, Type: board.Queen})
	b.Set(board.Point{X: 6, Y: 6}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	locked, direct := b.GetCheckingVectors(board.Down, board.Point{X: 5, Y: 5})

	require.Equal(t, locked, map[board.Point]board.Vector{{X: 10, Y: 10}: {Dx: -1, Dy: -1}})

	require.Equal(t, direct, map[board.Point]board.Vector{{X: 8, Y: 5}: {Dx: -1}})
}
