package websocket

import "fmt"

type Room struct {
	Register chan *Participant
	Clients  map[*Client]string //TODO: access by mutex
	Code     string
}

type Participant struct {
	Client *Client
	Name   string
}

func NewRoom() *Room {
	return &Room{
		Register: make(chan *Participant),
		Clients:  make(map[*Client]string),
	}
}

func (this *Room) Start() { //TODO: cant register more than four people
	for {
		select { //TODO: cant register if the game has already started or
		case participant := <-this.Register:
			this.Clients[participant.Client] = participant.Name
			fmt.Println("room: new user joined\ncount of connected players:", len(this.Clients))
			break
		}
	}
}

func (this *Room) Unregister(client *Client) {
	delete(this.Clients, client)
	fmt.Println("room: count of connected players:", len(this.Clients))
}

func (this *Room) Input(event ClientEvent) {
	fmt.Println("room: receiving input from client")
	if event.Message.Type == "room" {
		switch event.Message.SubType {
		case "leave":

			break
		default:
			//TODO: disconnect the client
		}
	}
}
