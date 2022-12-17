package chess

import (
	"fmt"
	"server/domain"
)

type Pieces int

const (
	Pawn Pieces = iota
	Rook
	Knight
	Bishop
	Queen
	King
)

type Game struct {
	Players   map[*domain.Client]*PlayerAttributes //the int represents the time this player has left, on mate/resign,.. the time is set to 0
	MoveOrder []*domain.Client
	Board     [14][14]*Piece
	Timer     *Timer
	Player    *domain.Client
	EnPassant []*Piece
}

type PlayerAttributes struct {
	Time int
	Name string
}

type Piece struct {
	Piece    Pieces
	Owner    *domain.Client
	HasMoved bool
}

func (this *Game) Start() {
	this.MoveOrder = make([]*domain.Client, len(this.Players))
	this.EnPassant = make([]*Piece, len(this.Players))
	var index = 0
	for player := range this.Players {
		this.MoveOrder[index] = player
		index++
	}
	this.generateBard()
	this.Player = this.MoveOrder[0]
	var time = int64(this.Players[this.Player].Time)
	this.Timer = NewTimer(time, this)
	go this.Timer.Start()
	this.Timer.startTime <- time
	for player := range this.Players {
		player.Write("game", "started", map[string]interface{}{"participants": this.namesOfParticipants(this.MoveOrder), "time": time})
	}
}

func (this *Game) Move(move [4]int, promotion string) {
	fmt.Println("player moved") //TODO: this is executed
	this.Timer.isStopped <- true
	this.Players[this.Player].Time = int(this.Timer.Time)
	nextPlayer := this.nextPlayer()
	if !this.validMove(move, promotion) {
		this.Player.Disconnect()
		return
	}
	fmt.Println("move accepted") //TODO: this is not executed
	switch promotion {
	case "":
		fmt.Println("no promotion")
		this.Board[move[2]][move[3]] = this.Board[move[0]][move[1]]
		this.Board[move[0]][move[1]] = nil
		break
	case "n":
		this.Board[move[2]][move[3]] = &Piece{Piece: Knight, Owner: this.Board[move[2]][move[3]].Owner, HasMoved: true}
		break
	case "b":
		this.Board[move[2]][move[3]] = &Piece{Piece: Bishop, Owner: this.Board[move[2]][move[3]].Owner, HasMoved: true}
		break
	case "r":
		this.Board[move[2]][move[3]] = &Piece{Piece: Rook, Owner: this.Board[move[2]][move[3]].Owner, HasMoved: true}
		break
	case "q":
		this.Board[move[2]][move[3]] = &Piece{Piece: Queen, Owner: this.Board[move[2]][move[3]].Owner, HasMoved: true}
		break
	default:
		this.Player.Disconnect()
		return
	}
	fmt.Println("sending confirmation")
	for player := range this.Players {
		if player != this.Player {
			player.Write("game", "moved", map[string]interface{}{
				"move": move, "promotion": promotion, "next-participant": nextPlayer, "remaining-time": this.Players[this.Player].Time,
			})
		}
	}
	this.Player.Write("game", "move-accepted", map[string]interface{}{
		"next-participant": nextPlayer, "remaining-time": this.Players[this.Player].Time,
	})
	this.Player = nextPlayer
	time := int64(this.Players[this.Player].Time)
	this.Timer = NewTimer(time, this)
	this.Timer.startTime <- time
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

func (this *Game) nextPlayer() *domain.Client { //TODO: test if this method s valid
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

func (this *Game) generateBard() {
	for p := 0; p < len(this.MoveOrder); p++ {
		this.Board[0] = [14]*Piece{
			nil, nil, nil,
			{Piece: Rook, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Knight, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Bishop, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: King, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Queen, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Bishop, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Knight, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Rook, Owner: this.MoveOrder[p], HasMoved: false},
			nil, nil, nil,
		}
		this.Board[1] = [14]*Piece{
			nil, nil, nil,
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			{Piece: Pawn, Owner: this.MoveOrder[p], HasMoved: false},
			nil, nil, nil,
		}
		for i := 0; i < 6; i++ { //rotate
			for j := i; j < 13-i; j++ {
				temp := this.Board[i][j]
				this.Board[i][j] = this.Board[13-j][i]
				this.Board[13-j][i] = this.Board[13-i][13-j]
				this.Board[13-i][14-1-j] = this.Board[j][13-i]
				this.Board[j][13-i] = temp
			}
		}
	}
}

func (this *Game) validMove(move [4]int, promotion string) bool {
	return true
}
