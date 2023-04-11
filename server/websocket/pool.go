package websocket

import (
	"log"
	"math/rand"
	"regexp"
	"server/domain"
	"sort"
	"strconv"
	"strings"
	"time"
	"unicode"
)

type Pool struct {
	Register         chan *domain.Client
	Clients          map[*domain.Client]bool
	Rooms            map[string]*Room
	UnregisterRoom   chan *Room
	UnregisterClient chan *domain.Client
	InputEvent       chan domain.ClientEvent
}

func NewPool() *Pool {
	return &Pool{
		Register:         make(chan *domain.Client),
		Clients:          make(map[*domain.Client]bool),
		Rooms:            make(map[string]*Room),
		UnregisterRoom:   make(chan *Room),
		UnregisterClient: make(chan *domain.Client),
		InputEvent:       make(chan domain.ClientEvent),
	}
}

func (p *Pool) Start() {
	for {
		select {
		case room := <-p.UnregisterRoom:
			var code string
			for _code, _room := range p.Rooms {
				if _room == room {
					code = _code
				}
			}
			delete(p.Rooms, code)
			break
		case client := <-p.Register:
			log.Println("TRACE register new client in pool")
			p.Clients[client] = true
			break
		case client := <-p.UnregisterClient:
			log.Println("TRACE unregister client in pool")
			delete(p.Clients, client)
			break
		case event := <-p.InputEvent:
			if event.Message.Type == "room" {
				switch event.Message.SubType {
				case "create":
					p.createRoom(event)
					break
				case "join":
					p.joinRoom(event)
					break
				default:
					log.Println("WARNING unexpected statement\n   => disconnecting client")
					event.Client.Disconnect()
					break
				}
			}
			break
		}
	}
}

func (p *Pool) Unregister(client *domain.Client) {
	p.UnregisterClient <- client
}

func (p *Pool) Input(event domain.ClientEvent) {
	p.InputEvent <- event
}

func (p *Pool) createRoom(event domain.ClientEvent) {
	var messageContent = event.Message.Content
	var client = event.Client
	var code = p.generateCode()
	var room = NewRoom(client, p)
	log.Println("TRACE new room '" + code + "'created")

	room.Participants.Lock()
	defer room.Participants.Unlock()

	var name = validateName(messageContent["name"].(string), room) // TODO: should not be casted to string
	go room.Start()
	p.Rooms[code] = room
	room.Register <- &Participant{client, name}
	client.Handler = room
	delete(p.Clients, client)
	client.Write("room", "created", map[string]interface{}{"code": code, "name": name})
}

func validateName(name string, room *Room) string {
	match := regexp.MustCompile(`\W`) //TODO: should name look like this? idk...
	name = match.ReplaceAllString(name, "")
	if name == "" {
		return generateName(room)
	}
	for client := range room.Participants.Clients {
		if name == room.Participants.Clients[client] {
			return generateName(room)
		}
	}
	return name
}

func (p *Pool) joinRoom(event domain.ClientEvent) {
	var content = event.Message.Content
	var client = event.Client
	var code = strings.ToUpper((content["code"]).(string)) // TODO: more string casting...
	var name = (content["name"]).(string)
	var room, exist = p.Rooms[code]

	if !exist { //TODO: is not true on false code
		log.Println("TRACE join in room '" + code + "' rejected\n   => reason: room was not found")
		client.Write("room", "join-failed", map[string]interface{}{"reason": "not found"})
		return
	}
	room.Participants.Lock()
	defer room.Participants.Unlock()
	name = validateName(name, room)
	if len(room.Participants.Clients) == 4 {
		log.Println("TRACE join in room '" + code + "' rejected\n   => reason: room is full")
		client.Write("room", "join-failed", map[string]interface{}{"reason": "full"})
		return
	}
	if room.IsInGame() {
		log.Println("TRACE join in room '" + code + "' rejected\n   => reason: room has already started")
		client.Write("room", "join-failed", map[string]interface{}{"reason": "started"})
		return
	}
	client.Handler = room
	var participant = Participant{client, name}
	room.Register <- &participant
	delete(p.Clients, client)
	client.Write("room", "joined", map[string]interface{}{"name": name})
}

const letterBytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func (p *Pool) generateCode() string {
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, 6)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	for code := range p.Rooms {
		if code == string(b) {
			return p.generateCode()
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
