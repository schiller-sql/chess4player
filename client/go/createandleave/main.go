package main

import (
	"flag"
	"log"
	"net/url"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/websocket"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

type Message struct {
	Type    string                 `json:"type"`
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

	c, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("dial:", err)
	}
	defer func(c *websocket.Conn) {
		err := c.Close()
		if err != nil {
			log.Println(err)
		}
	}(c)

	done := make(chan struct{})

	go func() {
		defer close(done)
		for {
			var message Message
			err := c.ReadJSON(&message)
			if err != nil {
				log.Println("read:", err)
				return
			}
			log.Printf("recv: %s", message)
			if message.Type == "room" && message.SubType == "created" {
				err = c.WriteJSON(Message{
					Type:    "room",
					SubType: "leave",
					Content: map[string]interface{}{},
				})
				if err != nil {
					log.Println("write:", err)
					return
				}
			}
		}
	}()

	err = c.WriteJSON(Message{
		Type:    "room",
		SubType: "create",
		Content: map[string]interface{}{
			"name": "Olevenbaum",
		},
	})
	if err != nil {
		log.Println("write:", err)
		return
	}

	for {
		select {
		case <-done:
			return
		case <-interrupt:
			log.Println("interrupt")

			// Cleanly close the connection by sending a close message and then
			// waiting (with timeout) for the server to close the connection.
			err := c.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("write close:", err)
				return
			}
			select {
			case <-done:
			case <-time.After(time.Second):
			}
			return
		}
	}
}
