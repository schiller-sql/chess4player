package chess

import (
	"server/domain"
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
	Players   map[*domain.Client]int //the int represents the time this player has left, on mate/resign,.. the time is set to 0
	MoveOrder []*domain.Client
	Board     [][]Piece
	Timer     *Timer
	Player    *domain.Client
}

func (this *Game) Start() {
	var index = 0
	for player := range this.Players {
		this.MoveOrder[index] = player
		index++
	}
	for i := 0; i < 8; i++ {
		if i == 0 || i == 7 {
			this.Board[i] = []Piece{Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook}
		} else if i == 1 || i == 6 {
			this.Board[i] = []Piece{Pawn, Pawn, Pawn, Pawn, Pawn, Pawn, Pawn, Pawn}
		} else {
			this.Board[i] = []Piece{}
		}
	}
	this.Player = this.MoveOrder[0]
	var time = int64(this.Players[this.Player])
	this.Timer = NewTimer(time, this)
	go this.Timer.Start()
	this.Timer.startTime <- time
}

func (this *Game) Move(move []int, promotion string) {
	this.Timer.isStopped <- true
	this.Players[this.Player] = int(this.Timer.Time)
	this.Player = this.nextPlayer()
	time := int64(this.Players[this.Player])
	this.Timer = NewTimer(time, this)
	this.Timer.startTime <- time
	//this.Time += int(time.Until(start) / time.Millisecond)
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

func (this *Game) nextPlayer() *domain.Client {
	for index, player := range this.MoveOrder {
		if player == this.Player {
			current := this.MoveOrder[index+1]
			if current == nil {
				return this.MoveOrder[0]
			} else {
				return current
			}
		}
	}
	return nil
}
