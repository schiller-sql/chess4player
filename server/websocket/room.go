package websocket

import (
	"log"
	"server/chess"
	"server/domain"
	"sync"
)

type Room struct {
	Register         chan *Participant
	Participants     *Participants
	InputEvent       chan domain.ClientEvent
	UnregisterClient chan *domain.Client
	Host             *domain.Client
	Pool             *Pool
	InGame           *InGame
	Game             *chess.Game
}

type InGame struct {
	value bool
	sync.Mutex
}

type Participants struct {
	Clients map[*domain.Client]string
	sync.Mutex
}

type Participant struct {
	Client *domain.Client
	Name   string
}

//TODO: mutex is not correctly set up in this file

func NewRoom(host *domain.Client, pool *Pool) *Room {
	return &Room{
		Register:         make(chan *Participant),
		Participants:     &Participants{Clients: make(map[*domain.Client]string)},
		InputEvent:       make(chan domain.ClientEvent),
		UnregisterClient: make(chan *domain.Client),
		Host:             host,
		Pool:             pool,
		InGame:           &InGame{value: false, Mutex: sync.Mutex{}},
		Game:             &chess.Game{Players: make(map[*domain.Client]*chess.PlayerAttributes)},
	}
}

func (this *Room) Start() { //TODO: cant register more than four people
	for {
		select {
		case participant := <-this.Register:
			log.Println("TRACE register new client in room")
			this.Participants.Lock()
			this.Participants.Clients[participant.Client] = participant.Name
			this.Participants.Unlock()
			if participant.Client != this.Host {
				this.participantCountUpdate()
			}
			break
		case client := <-this.UnregisterClient: //only called if client lost connection
			log.Println("INFO room lost connection to client")
			this.Participants.Lock()
			delete(this.Participants.Clients, client)
			delete(this.Game.Players, client) //TODO: remove player from game.moveOrder by resizing moveOrder
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
				this.Game.Player = client
				this.Game.Resign()
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

func (this *Room) Unregister(client *domain.Client) {
	this.UnregisterClient <- client
}

func (this *Room) Input(event domain.ClientEvent) {
	this.InputEvent <- event
}

func (this *Room) handleEvent(event domain.ClientEvent) {
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
	case "game":
		switch event.Message.SubType {
		case "start":
			log.Println("TRACE room started game")
			var content = event.Message.Content
			this.InGame.value = true
			for participant, name := range this.Participants.Clients {
				this.Game.Players[participant] = &chess.PlayerAttributes{Time: int((content["time"]).(float64)), Name: name}
			}
			this.Game.Start()
			break
		case "move":
			var content = event.Message.Content
			var move [4]int
			for i, v := range (content["move"]).([]interface{}) {
				move[i] = int(v.(float64))
			}
			this.Game.Move(move, (content["promotion"]).(string))
			break
		case "resign":
			this.Game.Resign()
			break
		case "draw-request":
			this.Game.DrawRequest(event.Client)
			break
		case "draw accept":
			this.Game.DrawAccept(event.Client)
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

func (this *Room) leaveRoom(event domain.ClientEvent) {
	log.Println("TRACE unregister client in room")
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
		delete(this.Game.Players, client) //TODO: remove player from game.moveOrder by resizing moveOrder
		this.Pool.Register <- client
		client.Handler = this.Pool
		this.participantCountUpdate()
		if this.InGame.value {
			this.Game.Player = client
			this.Game.Resign()
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
	log.Println("DEBUG room disbanded\n   => host left")
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
