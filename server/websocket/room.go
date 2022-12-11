package websocket

import "fmt"

type Room struct {
	Register   chan *Client
	Unregister chan *Client
	Clients    map[*Client]string
	Input      chan ClientEvent
	Code       string
}

func NewRoom() *Room {
	return &Room{
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
		Clients:    make(map[*Client]string),
		Input:      make(chan ClientEvent),
	}
}

func (this *Room) Start() {
	for {
		select {
		case client := <-this.Register:
			this.Clients[client] = client.name
			fmt.Println("pool: new user joined\nsize of connection pool:", len(this.Clients))
			break
		case client := <-this.Unregister:
			delete(this.Clients, client)
			fmt.Println("pool: size of connection pool", len(this.Clients))
			break
		}
	}
}
