package websocket

import (
	"fmt"
	"log"
	"math/rand"
	"strconv"
	"strings"
	"time"
)

//channels for concurrent communication, as well as a map of clients.

type Pool struct {
	Register chan *Client
	Clients  map[*Client]bool //a map of clients to a boolean value to dictate active/inactive but not disconnected further down the line based on browser focus.
	Rooms    map[string]*Room
}

func NewPool() *Pool {
	return &Pool{
		Register: make(chan *Client),
		Clients:  make(map[*Client]bool),
		Rooms:    make(map[string]*Room),
	}
}

func (this *Pool) Unregister(client *Client) {
	delete(this.Clients, client)
	fmt.Println("pool: size of connection pool", len(this.Clients))
}

func (this *Pool) Input(event ClientEvent) {
	fmt.Println("pool: receiving input from client")
	if event.Message.Type == "room" {
		switch event.Message.SubType {
		case "create":
			this.createRoom(event)
		case "join":

			break
		}
	}
}

func (this *Pool) Start() {
	fmt.Println("pool: pool started")
	for {
		select {
		case client := <-this.Register:
			this.Clients[client] = true
			fmt.Println("pool: new user joined\nsize of connection pool:", len(this.Clients))
		}
	}
}

func (this *Pool) createRoom(input ClientEvent) {
	var content = input.Message.Content
	var client = input.Client
	var code = this.generateCode()
	var room = NewRoom()
	var name = (content["name"]).(string)
	if name == "" { //TODO: replace all unwanted characters
		name = generateName(room)
	}

	this.Rooms[code] = room
	go room.Start()
	room.Clients[client] = name
	room.Register <- client
	delete(this.Clients, client)

	err := client.Conn.WriteJSON(Message{
		Type:    "room",
		SubType: "created",
		Content: map[string]interface{}{
			"code": code,
			"name": name},
	})
	if err != nil {
		log.Println(err)
		return
	}
}

const letterBytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func (this *Pool) generateCode() string {
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, 6)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	for _, room := range this.Rooms {
		if room.Code == string(b) {
			return this.generateCode()
		}
	}
	return string(b)
}

func generateName(room *Room) string {
	var count = 0
	for client, _ := range room.Clients {
		if !strings.Contains(room.Clients[client], "Player") {
			count++
		}
	}
	return "Player" + strconv.Itoa(count)
}
