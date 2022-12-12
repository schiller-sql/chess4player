package websocket

import (
	"fmt"
	"log"
	"math/rand"
	"strconv"
	"strings"
	"time"
)

type Pool struct {
	Register         chan *Client
	Clients          map[*Client]bool
	Rooms            map[string]*Room
	UnregisterRoom   chan *Room
	UnregisterClient chan *Client
	InputEvent       chan ClientEvent
}

func NewPool() *Pool {
	return &Pool{
		Register:         make(chan *Client),
		Clients:          make(map[*Client]bool),
		Rooms:            make(map[string]*Room),
		UnregisterRoom:   make(chan *Room),
		UnregisterClient: make(chan *Client),
		InputEvent:       make(chan ClientEvent),
	}
}

func (this *Pool) Start() {
	fmt.Println("pool: pool started")
	for {
		select {
		case client := <-this.Register:
			this.Clients[client] = true
			fmt.Println("pool: new user joined\nsize of connection pool:", len(this.Clients))
			break
		case client := <-this.UnregisterClient:
			delete(this.Clients, client)
			fmt.Println("pool: size of connection pool", len(this.Clients))
			break
		case event := <-this.InputEvent:
			fmt.Println("pool: receiving input from client")
			if event.Message.Type == "room" {
				switch event.Message.SubType {
				case "create":
					this.createRoom(event)
					break
				case "join":
					this.joinRoom(event)
					break
				default:
					//TODO: disconnect the client
				}
			}
			break
		}
	}
}

func (this *Pool) Unregister(client *Client) {
	this.UnregisterClient <- client
}

func (this *Pool) Input(event ClientEvent) {
	this.InputEvent <- event
}

func (this *Pool) createRoom(event ClientEvent) {
	var content = event.Message.Content
	var client = event.Client
	var code = this.generateCode()
	var room = NewRoom(client, this)
	var name = (content["name"]).(string)
	if name == "" { //TODO: replace all unwanted characters
		name = generateName(room)
	}

	this.Rooms[code] = room
	go room.Start()
	var participant = Participant{client, name}
	room.Register <- &participant
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

func (this *Pool) joinRoom(event ClientEvent) {
	var content = event.Message.Content
	var client = event.Client
	var code = (content["code"]).(string)
	var name = (content["name"]).(string)
	var room, exists = this.Rooms[code]
	if !exists {
		err := client.Conn.WriteJSON(Message{
			Type:    "room",
			SubType: "join-failed",
			Content: map[string]interface{}{
				"reason": "not found",
			},
		})
		if err != nil {
			log.Println(err)
			return
		}
		return
	}
	if len(room.Clients) > 3 {
		err := client.Conn.WriteJSON(Message{
			Type:    "room",
			SubType: "join-failed",
			Content: map[string]interface{}{
				"reason": "full",
			},
		})
		if err != nil {
			log.Println(err)
			return
		}
		return
	}
	//TODO: check here if the game has already started
	if name == "" {
		name = generateName(room)
	}
	for client := range room.Clients {
		if name == room.Clients[client] {
			name = generateName(room)
			break
		}
	}
	var participant = Participant{client, name}
	room.Register <- &participant
	delete(this.Clients, client)

	err := client.Conn.WriteJSON(Message{
		Type:    "room",
		SubType: "joined",
		Content: map[string]interface{}{
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
	for code, _ := range this.Rooms {
		if code == string(b) {
			return this.generateCode()
		}
	}
	return string(b)
}

func generateName(room *Room) string {
	var count = 0
	for client := range room.Clients {
		if !strings.Contains(room.Clients[client], "Player") {
			count++
		}
	}
	return "Player" + strconv.Itoa(count)
}
