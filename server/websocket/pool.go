package websocket

import (
	"fmt"
	"math/rand"
	"regexp"
	"sort"
	"strconv"
	"time"
	"unicode"
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
	fmt.Println("pool-debug: creating new room")
	var messageContent = event.Message.Content
	var client = event.Client
	var code = this.generateCode()
	var room = NewRoom(client, this)

	room.Participants.Lock()
	defer room.Participants.Unlock()

	var name = validateName(messageContent["name"].(string), room)
	go room.Start()
	this.Rooms[code] = room
	room.Register <- &Participant{client, name}
	client.Handler = room
	delete(this.Clients, client)
	client.Write("room", "created", map[string]interface{}{"code": code, "name": name})
}

func validateName(name string, room *Room) string {
	match := regexp.MustCompile(`[^a-zA-Z_0-9]`) //TODO: should name look like this? idk...
	name = match.ReplaceAllString(name, "")
	if name == "" {
		fmt.Println("pool-debug: generate name")
		return generateName(room)
	}
	return name
}

func (this *Pool) joinRoom(event ClientEvent) {
	fmt.Println("pool-debug: join room event triggered 0")
	var content = event.Message.Content
	var client = event.Client
	var code = (content["code"]).(string)
	var name = (content["name"]).(string)
	var room, exist = this.Rooms[code]

	if !exist {
		fmt.Println("pool-debug: room not found")
		client.Write("room", "join-failed", map[string]interface{}{"reason": "not found"})
		return
	}
	fmt.Println("pool-debug: room found")
	room.InGame.Lock()
	defer room.InGame.Unlock()
	room.Participants.Lock()
	defer room.Participants.Unlock()
	fmt.Println("pool-debug: mutex set")
	name = validateName(name, room)
	fmt.Println("pool-debug: join room event triggered 1")
	if len(room.Participants.Clients) > 3 {
		client.Write("room", "join-failed", map[string]interface{}{"reason": "full"})
		return
	}
	if room.InGame.value {
		client.Write("room", "join-failed", map[string]interface{}{"reason": "started"})
		return
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
	var names = make([]string, len(room.Participants.Clients))
	var i = 0
	for client := range room.Participants.Clients {
		var currentName = room.Participants.Clients[client]
		if len(currentName) == 7 && currentName[0:6] == "Player" && unicode.IsDigit(int32(currentName[6])) {
			names[i] = string(currentName[6])
			i++
		}
	}
	sort.Strings(names)
	var count = 1
	for _, name := range names {
		if name == strconv.Itoa(count) {
			count++
		}
	}
	return "Player" + strconv.Itoa(count)
}
