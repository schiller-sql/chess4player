package websocket

import (
	"fmt"
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

func NewRoom(host *Client, pool *Pool) *Room {
	return &Room{
		Register:         make(chan *Participant),
		Participants:     &Participants{Clients: make(map[*Client]string)},
		InputEvent:       make(chan ClientEvent),
		UnregisterClient: make(chan *Client),
		Host:             host,
		Pool:             pool,
		InGame:           &InGame{value: false, Mutex: sync.Mutex{}},
	}
}

func (this *Room) Start() { //TODO: cant register more than four people
	fmt.Println("room: room started")
	for {
		select {
		case participant := <-this.Register: //TODO: causes infinity loop
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
				this.hostLeft()
				break
			}
			this.participantCountUpdate()
			this.InGame.Lock()
			if this.InGame.value {
				this.participantResigned(client)
			}
			this.InGame.Unlock()
			break
		case event := <-this.InputEvent:
			{
				fmt.Println("room: received input from participant")
				if event.Message.Type == "room" {
					switch event.Message.SubType {
					case "leave":
						this.leaveRoom(event)
						break

					default:
						fmt.Println("room: unexpected statement\n   => disconnecting client")
						event.Client.Disconnect()
					}
				}
			}
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
	this.Participants.Lock()
	defer this.Participants.Unlock()
	this.Host.Write(
		"room",
		"participants-count-update",
		map[string]interface{}{"participants-count": len(this.Participants.Clients)})
}

func (this *Room) hostLeft() {
	this.Participants.Lock()
	defer this.Participants.Unlock()

	for client := range this.Participants.Clients {
		if client != this.Host {
			client.Write("room", "disbanded", map[string]interface{}{})
		}
	}
	this.Pool.UnregisterRoom <- this
	for client := range this.Participants.Clients {
		this.Pool.Register <- client
		client.Handler = this.Pool
	}
}

func (this *Room) participantResigned(participant *Client) {
	this.Participants.Lock()
	defer this.Participants.Unlock()

	for client := range this.Participants.Clients {
		if client != participant {
			client.Write("game", "player-lost", map[string]interface{}{"participant": this.Participants.Clients[participant], "reason": "resign"})
		}
	}
}
