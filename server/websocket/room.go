package websocket

import (
	"fmt"
	"log"
)

type Room struct {
	Register         chan *Participant
	Clients          map[*Client]string //TODO: access by mutex
	InputEvent       chan ClientEvent
	UnregisterClient chan *Client
	Host             *Client
	Pool             *Pool
	InGame           bool
}

type Participant struct {
	Client *Client
	Name   string
}

func NewRoom(host *Client, pool *Pool) *Room {
	return &Room{
		Register:         make(chan *Participant),
		Clients:          make(map[*Client]string),
		InputEvent:       make(chan ClientEvent),
		UnregisterClient: make(chan *Client),
		Host:             host,
		Pool:             pool,
		InGame:           false,
	}
}

func (this *Room) Start() { //TODO: cant register more than four people
	for {
		select { //TODO: cant register if the game has already started or
		case participant := <-this.Register:
			this.Clients[participant.Client] = participant.Name
			fmt.Println("room: new user joined\ncount of connected players:", len(this.Clients))
			break
		case client := <-this.UnregisterClient:
			delete(this.Clients, client)
			fmt.Println("room: count of connected players:", len(this.Clients))
			break
		case event := <-this.InputEvent:
			{
				fmt.Println("room: receiving input from client")
				if event.Message.Type == "room" {
					switch event.Message.SubType {
					case "leave":
						this.leaveRoom(event)
						break
					default:
						//TODO: disconnect the client
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
	var client = event.Client
	err := client.Conn.WriteJSON(Message{
		Type:    "room",
		SubType: "left",
		Content: map[string]interface{}{}})
	if err != nil {
		log.Println(err)
		return
	}

	if client == this.Host {
		for client := range this.Clients {
			if client != this.Host {
				err := client.Conn.WriteJSON(Message{
					Type:    "room",
					SubType: "disbanded",
					Content: map[string]interface{}{}})
				if err != nil {
					log.Println(err)
					return
				}
			}
		}
		for client := range this.Clients {
			this.Pool.Register <- client
		}
		this.Pool.UnregisterRoom <- this

	} else {

		err := this.Host.Conn.WriteJSON(Message{
			Type:    "room",
			SubType: "participants-count-update",
			Content: map[string]interface{}{
				"participants-count": len(this.Clients),
			}})
		if err != nil {
			log.Println(err)
			return
		}
		this.Pool.Register <- client
		delete(this.Clients, client)

		//TODO: only if in game and client is still alive:
		//	send to all player resigned
		if this.InGame {
			return
		}
		for client := range this.Clients {
			if client != event.Client {
				err := this.Host.Conn.WriteJSON(Message{
					Type:    "game",
					SubType: "player-lost",
					Content: map[string]interface{}{
						"participant": this.Clients[event.Client],
						"reason":      "resign",
					}})
				if err != nil {
					log.Println(err)
					return
				}
			}
		}
	}
}
