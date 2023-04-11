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

func TestBoardGenOnlyTwo(t *testing.T) {
	b := board.Board{}
	f := [4]bool{true, false, true, false}
	b.GenerateBoard(f)
	print(b.String())
	if b.IsInBoard(board.Point{Y: 14}) {
		t.Errorf("0|14 is not in board")
	}
	if !b.IsInBoard(board.Point{X: 8, Y: 8}) {
		t.Error()
	}
}

func TestShortCastle(t *testing.T) {
	b := board.Board{}

	b.Set(board.Point{X: 5, Y: 5}, board.NewPiece(board.Up, board.King))

	b.Set(board.Point{X: 5, Y: 8}, board.NewPiece(board.Up, board.Rook))
	print(b.String())

	b.Move(board.Point{X: 5, Y: 5}, board.Point{X: 5, Y: 7}, nil)
	print(b.String())

	if b.Get(board.Point{X: 5, Y: 7}).Type != board.King {
		t.Error()
	}

	if b.Get(board.Point{X: 5, Y: 6}).Type != board.Rook {
		t.Error()
	}
}

func TestLongCastle(t *testing.T) {
	b := board.Board{}

	b.Set(board.Point{X: 5, Y: 5}, board.NewPiece(board.Up, board.King))

	b.Set(board.Point{X: 1, Y: 5}, board.NewPiece(board.Up, board.Rook))
	print(b.String())

	b.Move(board.Point{X: 5, Y: 5}, board.Point{X: 3, Y: 5}, nil)
	print(b.String())

	if b.Get(board.Point{X: 3, Y: 5}).Type != board.King {
		t.Error()
	}

	if b.Get(board.Point{X: 4, Y: 5}).Type != board.Rook {
		t.Error()
	}
}

func TestCheckMateThreeRooks(t *testing.T) {
	b := board.Board{}
	b.Set(board.Point{Y: 4}, &board.Piece{Direction: board.Up, Type: board.Rook})
	b.Set(board.Point{Y: 5}, &board.Piece{Direction: board.Up, Type: board.Rook})
	b.Set(board.Point{Y: 6}, &board.Piece{Direction: board.Up, Type: board.Rook})

	b.Set(board.Point{X: 5, Y: 5}, &board.Piece{Direction: board.Down, Type: board.King})

	if checkMate, remi := b.CheckEndForDirection(board.Down); !checkMate || remi {
		t.Error()
	}

	// rook that can save king
	b.Set(board.Point{X: 4, Y: 3}, &board.Piece{Direction: board.Down, Type: board.Rook})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
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

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// pawn attacking one escape
	b.Set(board.Point{X: 6, Y: 7}, &board.Piece{Direction: board.Up, Type: board.Pawn})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// pawn attacking other escape
	b.Set(board.Point{X: 7, Y: 4}, &board.Piece{Direction: board.Left, Type: board.Pawn})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi { // queen still attackable
		t.Error()
	}

	// protect queen with knight, now queen is not attackable
	b.Set(board.Point{X: 3, Y: 2}, &board.Piece{Direction: board.Left, Type: board.Knight})

	// is checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Down); !checkMate || remi {
		t.Error()
	}

	// pawn +1 under queen protects the space +2 under the queen
	b.Set(board.Point{X: 4, Y: 5}, &board.Piece{Direction: board.Left, Type: board.Pawn})

	// king can go to this position
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// block this position with own piece
	b.Set(board.Point{X: 4, Y: 6}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	// checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Down); !checkMate || remi {
		t.Error()
	}

	// pawn that can attack queen
	b.Set(board.Point{X: 3, Y: 3}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	// no checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
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

func TestBoard_remi(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Down, Type: board.King})

	// add rook to attack the 3 fields the king could go to
	b.Set(board.Point{X: 4, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Rook})

	// not remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// add rook to attack the last 2 fields the king could go to
	b.Set(board.Point{X: 5, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Rook})

	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || !remi {
		t.Error()
	}

	// add pawn on side of king
	b.Set(board.Point{X: 7, Y: 7}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// put pawn of same piece before pawn and before that a rook of other team
	b.Set(board.Point{X: 7, Y: 8}, &board.Piece{Direction: board.Down, Type: board.Pawn})
	b.Set(board.Point{X: 7, Y: 9}, &board.Piece{Direction: board.Up, Type: board.Rook})

	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || !remi {
		t.Error()
	}

	// add diagonally in front of the pawns a piece that can be attacked by the pawn
	b.Set(board.Point{X: 8, Y: 8}, &board.Piece{Direction: board.Up, Type: board.Rook})

	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// replace this attackable piece with a non attackable one
	b.Set(board.Point{X: 8, Y: 8}, &board.Piece{Direction: board.Down, Type: board.Knight})

	// because this is a knight however, the knight can still move => no remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	b.Set(board.Point{X: 8, Y: 8}, nil)
	// remove the knight => not attackable piece => remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || !remi {
		t.Error()
	}
}

func Test_kngiht_remi(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Down, Type: board.King})

	// add rook to attack the 3 fields the king could go to
	b.Set(board.Point{X: 4, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Rook})

	// not remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// add rook to attack the last 2 fields the king could go to
	b.Set(board.Point{X: 5, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Rook})

	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || !remi {
		t.Error()
	}

	// knight in corner
	b.Set(board.Point{X: 10, Y: 0}, &board.Piece{Direction: board.Down, Type: board.Knight})

	// no remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}

	// cover knight spaces with pawns of same team
	b.Set(board.Point{X: 8, Y: 1}, &board.Piece{Direction: board.Down, Type: board.Pawn})
	b.Set(board.Point{X: 9, Y: 2}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	// no remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || remi {
		t.Error()
	}
	// cover pawns with enemy pawns
	b.Set(board.Point{X: 8, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	b.Set(board.Point{X: 9, Y: 3}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || !remi {
		t.Error()
	}
}

func TestBishopRemi(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Up, Type: board.King})

	// bishop and pawns blocking everything, except one field for bishop
	// bishop diagonally right behind king
	b.Set(board.Point{X: 4, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Bishop})
	// next to king
	b.Set(board.Point{X: 4, Y: 0}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	b.Set(board.Point{X: 5, Y: 0}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	// left and right next to bishop
	b.Set(board.Point{X: 3, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	b.Set(board.Point{X: 5, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	// right behind bishop (left is free for bishop to go => not remi)
	b.Set(board.Point{X: 5, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Pawn})

	// not remi
	if checkMate, remi := b.CheckEndForDirection(board.Up); checkMate || remi {
		t.Error()
	}

	// close field with opposing pawn, still attackable by bishop
	b.Set(board.Point{X: 3, Y: 2}, &board.Piece{Direction: board.Down, Type: board.Pawn})
	// not remi
	if checkMate, remi := b.CheckEndForDirection(board.Up); checkMate || remi {
		t.Error()
	}

	// close field with own opposing pawn, bishop now has nothing left to attack
	b.Set(board.Point{X: 3, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Pawn})

	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Up); checkMate || !remi {
		t.Error()
	}
}

func TestLockingPawns1(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Up, Type: board.King})
	// pawn in front
	b.Set(board.Point{X: 3, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Pawn})
	// two enemy rooks in direction of king, one that can be attacked by pawn,
	// if it were not locked to king
	b.Set(board.Point{X: 3, Y: 2}, &board.Piece{Direction: board.Down, Type: board.Rook})
	b.Set(board.Point{X: 4, Y: 2}, &board.Piece{Direction: board.Down, Type: board.Rook})

	if checkMate, remi := b.CheckEndForDirection(board.Up); checkMate || !remi {
		t.Error()
	}
}

func TestLockingPawnsNonAttack(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Down, Type: board.King})

	// pawn next to king (right)
	b.Set(board.Point{X: 4, Y: 0}, &board.Piece{Direction: board.Down, Type: board.Pawn})

	// two rooks attacking from side
	b.Set(board.Point{X: 5, Y: 0}, &board.Piece{Direction: board.Right, Type: board.Rook})
	b.Set(board.Point{X: 5, Y: 1}, &board.Piece{Direction: board.Right, Type: board.Rook})
	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Down); checkMate || !remi {
		t.Error()
	}
}

func TestPawnDoubleForwardCanSaveMate(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Up, Type: board.King})

	// attacking rooks
	b.Set(board.Point{X: 5, Y: 0}, &board.Piece{Direction: board.Down, Type: board.Rook})
	b.Set(board.Point{X: 5, Y: 1}, &board.Piece{Direction: board.Down, Type: board.Rook})

	// checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Up); !checkMate || remi {
		t.Error()
	}

	// saving pawn
	b.Set(board.Point{X: 4, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Pawn})

	// not checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Up); checkMate || remi {
		t.Error()
	}
}

func TestLockedPawnThatCanMoveIntoRookAsLastMove(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Right, Type: board.King})

	// protecting pawns
	b.Set(board.Point{X: 4, Y: 0}, &board.Piece{Direction: board.Right, Type: board.Pawn})

	// attacking rooks
	b.Set(board.Point{X: 6, Y: 0}, &board.Piece{Direction: board.Down, Type: board.Rook})
	b.Set(board.Point{X: 6, Y: 1}, &board.Piece{Direction: board.Down, Type: board.Rook})

	// not remi because pawn can still move
	if checkMate, remi := b.CheckEndForDirection(board.Right); checkMate || remi {
		t.Error()
	}

	// add pawn in front of other pawn, but know the original pawn can hit the rook
	b.Set(board.Point{X: 5, Y: 0}, &board.Piece{Direction: board.Right, Type: board.Pawn})

	// not remi
	if checkMate, remi := b.CheckEndForDirection(board.Right); checkMate || remi {
		t.Error()
	}

	// move the one tower back, so it cannot be hit by the pawn
	b.Set(board.Point{X: 6, Y: 1}, nil)
	b.Set(board.Point{X: 7, Y: 1}, &board.Piece{Direction: board.Down, Type: board.Rook})

	// remi
	if checkMate, remi := b.CheckEndForDirection(board.Right); checkMate || !remi {
		t.Error()
	}
}

func TestAttackingPawnCanSaveRemi(t *testing.T) {
	b := board.Board{}

	// king in corner
	b.Set(board.Point{X: 3, Y: 0}, &board.Piece{Direction: board.Right, Type: board.King})

	// queen attacking
	b.Set(board.Point{X: 5, Y: 2}, &board.Piece{Direction: board.Up, Type: board.Queen})

	// knights that block rest of ways for king
	b.Set(board.Point{X: 4, Y: 3}, &board.Piece{Direction: board.Up, Type: board.Knight})
	b.Set(board.Point{X: 6, Y: 1}, &board.Piece{Direction: board.Up, Type: board.Knight})

	// checkmate
	if checkMate, remi := b.CheckEndForDirection(board.Right); !checkMate || remi {
		t.Error()
	}

	// pawn from color of king blocking king diagonally but protecting from queen
	b.Set(board.Point{X: 4, Y: 1}, &board.Piece{Direction: board.Right, Type: board.Pawn})

	// not remi
	if checkMate, remi := b.CheckEndForDirection(board.Right); checkMate || remi {
		t.Error()
	}
}

// TODO: test locking vectors and saving on knights, bishops, rooks and queen
