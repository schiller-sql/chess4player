package chess

import (
	"server/websocket"
)

type Piece int

const (
	Pawn Piece = iota
	Rook
	Knight
	Bishop
	Queen
	King
)

type Game struct {
	Players map[*websocket.Client]bool
	Time    int
	Board   [][]Piece
}

func (this *Game) Start(time int) {

}

func (this *Game) Move(move []int, promotion string) {
	switch promotion {
	case "":
		break
	case "r":
		break
	case "n":
		break
	case "b":
		break
	case "q":
		break
	default:
		break
	}
}

func (this *Game) Resign() {

}

func (this *Game) DrawRequest() {

}

func (this *Game) DrawAccept() {

}
