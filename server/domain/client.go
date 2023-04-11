package domain

import (
	"github.com/gorilla/websocket"
	"log"
	"sync"
)

type Client struct {
	Conn    *websocket.Conn
	Handler Handler
	sync.Mutex
}

type Message struct {
	Type    string                 `json:"type"`
	SubType string                 `json:"subtype"`
	Content map[string]interface{} `json:"content"`
}

type returnMessage struct {
	Type    string      `json:"type"`
	SubType string      `json:"subtype"`
	Content interface{} `json:"content"`
}

type ClientEvent struct {
	Message Message
	Client  *Client
}

func (c *Client) Read() {
	for {
		var input Message
		err := c.Conn.ReadJSON(&input)
		if err != nil {
			log.Println("ERROR ", err)
			c.Disconnect()
			c.Handler.Unregister(c)
			return
		}
		c.Handler.Input(ClientEvent{input, c})
	}
}

func (c *Client) Write(returnType string, returnSubType string, returnContent interface{}) {
	c.Mutex.Lock()
	err := c.Conn.WriteJSON(returnMessage{
		Type:    returnType,
		SubType: returnSubType,
		Content: returnContent,
	})
	if err != nil {
		log.Println("ERROR ", err)
	}
	c.Mutex.Unlock()
}

func (c *Client) Disconnect() {
	log.Println("DEBUG disconnecting client")
	c.Handler.Unregister(c)
	err := c.Conn.Close()
	if err != nil {
		log.Println("ERROR ", err)
		return
	}
}
