package websocket

import (
	"log"
	"server/chess"
	"sync"
)

type Room struct {
	Register         chan *Participant
	Participants     *Participants
	InputEvent       chan ClientEvent
	UnregisterClient chan *Client
	Host             *Client
	Pool             *Pool
	InGame           *InGame
	Game             *chess.Game
}

type InGame struct {
	value bool
	sync.Mutex
}

type Participants struct {
	Clients map[*Client]string
	sync.Mutex
}

type Participant struct {
	Client *Client
	Name   string
}

//TODO: mutex is not correctly set up in this file

func NewRoom(host *Client, pool *Pool) *Room {
	return &Room{
		Register:         make(chan *Participant),
		Participants:     &Participants{Clients: make(map[*Client]string)},
		InputEvent:       make(chan ClientEvent),
		UnregisterClient: make(chan *Client),
		Host:             host,
		Pool:             pool,
		InGame:           &InGame{value: false, Mutex: sync.Mutex{}},
		Game:             &chess.Game{Players: make(map[*Client]bool), Time: 600000, Board: make([][]chess.Piece, 8)},
	}
}

func (this *Room) Start() { //TODO: cant register more than four people
	for {
		select {
		case participant := <-this.Register:
			this.Participants.Lock()
			this.Participants.Clients[participant.Client] = participant.Name
			this.Participants.Unlock()
			if participant.Client != this.Host {
				this.participantCountUpdate()
			}
			break
		case client := <-this.UnregisterClient: //only called if client lost connection
			this.Participants.Lock()
			delete(this.Participants.Clients, client)
			this.Participants.Unlock()
			if client == this.Host {
				this.Participants.Lock()
				this.hostLeft()
				this.Participants.Unlock()
				break
			}
			this.participantCountUpdate()
			this.InGame.Lock()
			if this.InGame.value {
				this.Participants.Lock()
				this.participantResigned(client)
				this.Participants.Unlock()
			}
			this.InGame.Unlock()
			break
		case event := <-this.InputEvent:
			this.handleEvent(event)
			break
		}
	}
}

func (this *Room) Unregister(client *Client) {
	this.UnregisterClient <- client
}

func (this *Room) Input(event ClientEvent) {
	this.InputEvent <- event
}

func (this *Room) handleEvent(event ClientEvent) {
	switch event.Message.Type {
	case "room":
		switch event.Message.SubType {
		case "leave":
			this.leaveRoom(event)
			break
		default:
			log.Println("WARNING unexpected statement\n   => disconnecting client")
			event.Client.Disconnect()
			break
		}
		break
	case "game": //TODO:
		switch event.Message.SubType {
		case "start":
			var content = event.Message.Content
			this.InGame.value = true
			this.Game.Start((content["time"]).(int))
			break
		case "move":
			var content = event.Message.Content
			this.Game.Move((content["move"]).([]int), (content["promotion"]).(string))
			break
		case "resign":
			this.Game.Resign()
			break
		case "draw-request":
			this.Game.DrawRequest()
			break
		case "draw accept":
			this.Game.DrawAccept()
			break
		default:
			log.Println("WARNING unexpected statement\n   => disconnecting client")
			event.Client.Disconnect()
			break
		}
	default:
		log.Println("WARNING unexpected statement\n   => disconnecting client")
		event.Client.Disconnect()
		break
	}
}

func (this *Room) leaveRoom(event ClientEvent) {
	this.Participants.Lock()
	defer this.Participants.Unlock()
	this.InGame.Lock()
	defer this.InGame.Unlock()
	var client = event.Client
	client.Write("room", "left", map[string]interface{}{})
	if client == this.Host {
		this.hostLeft()
	} else {
		delete(this.Participants.Clients, client)
		this.Pool.Register <- client
		client.Handler = this.Pool
		this.participantCountUpdate()
		if this.InGame.value {
			this.participantResigned(client)
		}
	}
}

func (this *Room) participantCountUpdate() {
	this.Host.Write(
		"room",
		"participants-count-update",
		map[string]interface{}{"participants-count": len(this.Participants.Clients)})
}

func (this *Room) hostLeft() { //TODO: does not work correctly
	for client := range this.Participants.Clients {
		if client != this.Host {
			client.Write("room", "disbanded", map[string]interface{}{})
		}
	}
	for client := range this.Participants.Clients {
		this.Pool.Register <- client
		client.Handler = this.Pool
	}
	this.Pool.UnregisterRoom <- this
}

func (this *Room) participantResigned(participant *Client) {
	for client := range this.Participants.Clients {
		if client != participant {
			client.Write("game", "player-lost", map[string]interface{}{"participant": this.Participants.Clients[participant], "reason": "resign"})
		}
	}
}
