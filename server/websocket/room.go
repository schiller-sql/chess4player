package websocket

import (
	"log"
	"server/domain"
	"sync"
)

type Room struct {
	Register               chan *Participant
	Participants           *Participants
	InputEvent             chan domain.ClientEvent
	UnregisterClient       chan *domain.Client
	Host                   *domain.Client
	Pool                   *Pool
	GameHasEverBeenCreated *InGame
	game                   *Game
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
		Register:               make(chan *Participant),
		Participants:           &Participants{Clients: make(map[*domain.Client]string)},
		InputEvent:             make(chan domain.ClientEvent),
		UnregisterClient:       make(chan *domain.Client),
		Host:                   host,
		Pool:                   pool,
		GameHasEverBeenCreated: &InGame{value: false, Mutex: sync.Mutex{}},
	}
}

func (r *Room) IsInGame() bool {
	r.GameHasEverBeenCreated.Lock()
	defer r.GameHasEverBeenCreated.Unlock()
	if r.GameHasEverBeenCreated.value == false {
		return false
	}
	return !r.game.HasEnded()
}

func (r *Room) Start() { //TODO: cant register more than four people
	for {
		select {
		case participant := <-r.Register:
			log.Println("TRACE register new client in room")
			r.Participants.Lock()
			r.Participants.Clients[participant.Client] = participant.Name
			if participant.Client != r.Host {
				r.sendHostParticipantCountUpdate()
			}
			r.Participants.Unlock()
			break
		case client := <-r.UnregisterClient: //only called if client lost connection
			endsGame := r.leaveRoom(client)
			if endsGame {
				return
			}
			break
		case event := <-r.InputEvent:
			switch event.Message.Type {
			case "room":
				switch event.Message.SubType {
				case "leave":
					endsGame := r.leaveRoom(event.Client)
					if endsGame {
						return
					}
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
					if r.IsInGame() {
						break
					}
					if event.Client != r.Host {
						event.Client.Disconnect()
						break
					}
					// TODO: what to do if only 1 partiicpant?????, now: ignore
					var content = event.Message.Content
					r.GameHasEverBeenCreated.Lock()
					r.GameHasEverBeenCreated.value = true
					time := uint((content["time"]).(float64)) // TODO cast
					r.Participants.Lock()
					if len(r.Participants.Clients) == 1 {
						break
					}
					r.GameHasEverBeenCreated.value = true
					r.game = StartGame(r.Participants.Clients, time)
					r.Participants.Unlock()
					r.GameHasEverBeenCreated.Unlock()
					break
				default:
					r.GameHasEverBeenCreated.Lock()
					inGame := r.GameHasEverBeenCreated.value
					r.GameHasEverBeenCreated.Unlock()
					if !inGame {
						break
					}
					r.game.Event(event)
				}
			default:
				log.Println("WARNING unexpected statement\n   => disconnecting client")
				event.Client.Disconnect()
				break
			}
		}
	}
}

func (r *Room) Unregister(client *domain.Client) {
	r.UnregisterClient <- client
}

func (r *Room) Input(event domain.ClientEvent) {
	r.InputEvent <- event
}

func (r *Room) leaveRoom(client *domain.Client) (endsGame bool) {
	r.Participants.Lock()
	defer r.Participants.Unlock()
	client.Write("room", "left", map[string]interface{}{})
	if client == r.Host {
		r.hostLeft()
		if r.GameHasEverBeenCreated.value {
			r.game.ForceGameEnd()
		}
		return true
	}
	if r.IsInGame() {
		r.game.LeavesRoom(client)
	}
	delete(r.Participants.Clients, client)
	r.sendHostParticipantCountUpdate()
	client.Handler = r.Pool
	r.Pool.Register <- client
	return false
}

func (r *Room) sendHostParticipantCountUpdate() {
	r.Host.Write(
		"room",
		"participants-count-update",
		map[string]interface{}{"participants-count": len(r.Participants.Clients)})
}

func (r *Room) hostLeft() { //TODO: does not work correctly TODO: FIX!!!!!
	log.Println("DEBUG room disbanded\n   => host left")
	for client := range r.Participants.Clients {
		if client != r.Host {
			client.Write("room", "disbanded", map[string]interface{}{})
		}
	}
	for client := range r.Participants.Clients {
		r.Pool.Register <- client
		client.Handler = r.Pool
	}
	r.Pool.UnregisterRoom <- r
}
