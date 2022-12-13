package main

import (
	"bufio"
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/url"
	"os"
	"os/signal"
	"strconv"
	"strings"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

type Message struct {
	Type    string                 `json:"type:"`
	SubType string                 `json:"subtype"`
	Content map[string]interface{} `json:"content"`
}

func main() {
	flag.Parse()
	log.SetFlags(0)
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)
	u := url.URL{Scheme: "ws", Host: *addr, Path: "/"}
	log.Printf("connecting to %s", u.String())
	conn, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("dial:", err)
	}
	defer func(c *websocket.Conn) {
		err := c.Close()
		if err != nil {
			log.Println("close", err)
		}
	}(conn)
	inputEvent := make(chan string)
	socketEvent := make(chan Message)

	go func() {
		defer close(inputEvent)
		for {
			consoleReader := bufio.NewReader(os.Stdin)
			fmt.Print(">")
			input, _ := consoleReader.ReadString('\n')
			if strings.HasPrefix(input, "exit") {
				err := conn.Close()
				if err != nil {
					log.Println("close:", err)
					return
				}
				os.Exit(0)
			}
			inputEvent <- input
		}
	}()

	go func() {
		for {
			var message Message
			err := conn.ReadJSON(&message)
			if err != nil {
				log.Println("read:", err)
				return
			}
			log.Printf("recv: %s", message)
			socketEvent <- message
		}
	}()

	for {
		select {
		case <-interrupt:
			log.Println("interrupt")
			err := conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("write close:", err)
				return
			}
			err = conn.Close()
			if err != nil {
				log.Println("close:", err)
				return
			}
			return
		case order := <-inputEvent:
			switch {
			case strings.Contains(order, "create"):
				name := order[7 : len(order)-1]
				write(conn, "room", "create", map[string]interface{}{"name": name})
				break
			case strings.Contains(order, "join"):
				code := order[5 : len(order)-1]
				write(conn, "room", "join", map[string]interface{}{"code": code, "name": ""})
				break
			case strings.Contains(order, "leave"):
				write(conn, "room", "leave", map[string]interface{}{})
				break
			}
			break
		case input := <-socketEvent:
			switch input.Type {
			case "room":
				switch input.SubType {
				case "participants-count-update":
					fmt.Println("participants-count-update: " + strconv.Itoa(int(input.Content["participants-count"].(float64))))
				}
			}
			break
		}
	}
}

func write(conn *websocket.Conn, messageType string, messageSubType string, messageContent map[string]interface{}) {
	err := conn.WriteJSON(Message{
		Type:    messageType,
		SubType: messageSubType,
		Content: messageContent,
	})
	if err != nil {
		log.Println(err)
		return
	}
}
