package websocket

import "fmt"

type Pool struct {
	Register   chan *Client
	Unregister chan *Client
	Clients    map[*Client]bool
	Broadcast  chan Message
}

func NewPool() *Pool {
	return &Pool{
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
		Clients:    make(map[*Client]bool),
		Broadcast:  make(chan Message),
	}
}

func (this *Pool) Start() {
	for {
		select {
		case client := <-this.Register:
			this.Clients[client] = true
			fmt.Println("Size of Connection pool", len(this.Clients))
			for client, _ := range this.Clients {
				fmt.Println(client)
				client.Conn.WriteJSON(Message{Type: 1, Body: "New User Joined..."})
			}
			break
		case client := <-this.Unregister:
			delete(this.Clients, client)
			fmt.Println("Size of Connection pool", len(this.Clients))
			for client, _ := range this.Clients {
				client.Conn.WriteJSON(Message{Type: 1, Body: "User Disconnected..."})
			}
			break
		case message := <-this.Broadcast:
			fmt.Println("Sending messageInput to all clients in pool")
			for client, _ := range this.Clients {
				if err := client.Conn.WriteJSON(message); err != nil {
					fmt.Println(err)
					return
				}
			}
		}
	}
}
