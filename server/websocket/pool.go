package websocket

import "fmt"

/*
channels for concurrent communication,
as well as a map of clients.
*/
type Pool struct {
	Register   chan *Client     //Our register channel will send out New User Joined... to all of the clients within this pool when a new client connects.
	Unregister chan *Client     //Will unregister a user and notify the pool when a client disconnects.
	Clients    map[*Client]bool // a map of clients to a boolean value to dictate active/inactive but not disconnected further down the line based on browser focus.
	Broadcast  chan Message     //a channel which, when it is passed a message, will loop through all clients in the pool and send the message through the socket connection.
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
