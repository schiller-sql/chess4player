package websocket

import (
	"fmt"
	"github.com/gorilla/websocket"
	"log"
)

type Client struct {
	Id   string          //a uniquely identifiably string for a particular connection
	Conn *websocket.Conn // pointer to a websocket.Conn object
	Pool *Pool           //pointer to the Pool which this client will be part of
}

type Message struct {
	Type int    `json:"type:"`
	Body string `json:"body"`
}

/*
If there are any messages, it will pass these messages to the Pool’s Broadcast channel
which subsequently broadcasts the received message to every client within the pool.
*/
func (c *Client) Read() {
	defer func() {
		c.Pool.Unregister <- c
		c.Conn.Close()
	}()

	for {
		messageType, p, err := c.Conn.ReadMessage()
		if err != nil {
			log.Println(err)
			return
		}
		message := Message{Type: messageType, Body: string(p)}
		c.Pool.Broadcast <- message
		fmt.Printf("MessageInput Received: %+v\n", message)
	}
}
