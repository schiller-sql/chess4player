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
	Players   map[*domain.Client]*PlayerAttributes //the int represents the time this player has left, on mate/resign,.. the time is set to 0
	MoveOrder []*domain.Client
	Board     [][]Piece
	Timer     *Timer
	Player    *domain.Client
}

type PlayerAttributes struct {
	Time int
	Name string
}

func (this *Game) Start() {
	this.MoveOrder = make([]*domain.Client, len(this.Players))
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
	var time = int64(this.Players[this.Player].Time)
	this.Timer = NewTimer(time, this)
	go this.Timer.Start()
	this.Timer.startTime <- time
	for player := range this.Players {
		player.Write("game", "started", map[string]interface{}{"participants": this.namesOfParticipants(this.MoveOrder), "time": time})
	}
}

func (this *Game) Move(move []int, promotion string) {
	this.Timer.isStopped <- true
	this.Players[this.Player].Time = int(this.Timer.Time)
	this.Player = this.nextPlayer()
	time := int64(this.Players[this.Player].Time)
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
	for client := range this.Players {
		client.Write("game", "player-lost", map[string]interface{}{"participant": this.Players[this.Player].Name, "reason": "resign"})
	}
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

func (this *Game) namesOfParticipants(participants []*domain.Client) []string {
	names := make([]string, len(participants))
	for index, participant := range participants {
		names[index] = this.Players[participant].Name
	}
	return names
}
