package domain

import (
	"github.com/gorilla/websocket"
	"log"
)

type Client struct {
	Conn    *websocket.Conn
	Handler Handler
}

type Message struct {
	Type    string                 `json:"type"`
	SubType string                 `json:"subtype"`
	Content map[string]interface{} `json:"content"`
}

type ClientEvent struct {
	Message Message
	Client  *Client
}

func (this *Client) Read() {
	defer func() {
		this.Disconnect()
	}()

	for {
		var input Message
		err := this.Conn.ReadJSON(&input)
		if err != nil {
			log.Println("ERROR ", err)
			this.Disconnect()
			return
		}
		this.Handler.Input(ClientEvent{input, this})
	}
}

func (this *Client) Write(returnType string, returnSubType string, returnContent map[string]interface{}) {
	err := this.Conn.WriteJSON(Message{
		Type:    returnType,
		SubType: returnSubType,
		Content: returnContent,
	})
	if err != nil {
		log.Println("ERROR ", err)
		return
	}
}

func (this *Client) Disconnect() {
	log.Println("DEBUG disconnecting client")
	this.Handler.Unregister(this)
	err := this.Conn.Close()
	if err != nil {
		log.Println("ERROR ", err)
		return
	}
}
