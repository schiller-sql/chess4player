package websocket

import (
	"fmt"
	"math/rand"
	"regexp"
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
			fmt.Println("pool: new size of connection pool:", len(this.Clients))
			break
		case client := <-this.UnregisterClient:
			delete(this.Clients, client)
			fmt.Println("pool: new size of connection pool", len(this.Clients))
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
					fmt.Println("pool: unexpected statement\n   => disconnecting client")
					event.Client.Disconnect()
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
	fmt.Println("creating new room")
	var messageContent = event.Message.Content
	var client = event.Client
	var code = this.generateCode()
	var room = NewRoom(client, this)
	var name = (messageContent["name"]).(string)
	match := regexp.MustCompile(`[^a-zA-Z_0-9]`) //TODO: should name look like this? idk...
	name = match.ReplaceAllString(name, "")
	if name == "" {
		name = generateName(room)
	}
	//TODO: server is stuck after this print
	go room.Start()
	this.Rooms[code] = room
	room.Register <- &Participant{client, name}
	client.Handler = room
	delete(this.Clients, client)
	client.Write("room", "created", map[string]interface{}{"code": code, "name": name})
}

func (this *Pool) joinRoom(event ClientEvent) {
	var content = event.Message.Content
	var client = event.Client
	var code = (content["code"]).(string)
	var name = (content["name"]).(string)
	var room, exists = this.Rooms[code]

	if !exists {
		room.InGame.Lock()
		defer room.InGame.Unlock()
		room.Participants.Lock()
		defer room.Participants.Unlock()

		client.Write("room", "join-failed", map[string]interface{}{"reason": "not found"})
		return
	}
	if len(room.Participants.Clients) > 3 {
		client.Write("room", "join-failed", map[string]interface{}{"reason": "full"})
		return
	}
	if room.InGame.value {
		client.Write("room", "join-failed", map[string]interface{}{"reason": "started"})
		return
	}
	if name == "" {
		name = generateName(room)
	}
	for client := range room.Participants.Clients {
		if name == room.Participants.Clients[client] {
			name = generateName(room)
			break
		}
	}
	client.Handler = room
	var participant = Participant{client, name}
	room.Register <- &participant
	delete(this.Clients, client)
	client.Write("room", "joined", map[string]interface{}{"name": name})
}

const letterBytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func (this *Pool) generateCode() string {
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, 6)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	for code := range this.Rooms {
		if code == string(b) {
			return this.generateCode()
		}
	}
	return string(b)
}

func generateName(room *Room) string {
	room.Participants.Lock()
	defer room.Participants.Unlock()

	var count = 0
	for client := range room.Participants.Clients {
		if !strings.Contains(room.Participants.Clients[client], "Player") {
			count++
		}
	}
	return "Player" + strconv.Itoa(count)
}
