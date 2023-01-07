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

type returnMessage struct {
	Type    string      `json:"type"`
	SubType string      `json:"subtype"`
	Content interface{} `json:"content"`
}

type ClientEvent struct {
	Message Message
	Client  *Client
}

func (this *Client) Read() {
	defer func() {
		// TODO: fehlt was?
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

// TODO: allowed for multiple writes parallel?
// TDOO: does mutex have to be used on client????
func (this *Client) Write(returnType string, returnSubType string, returnContent interface{}) {
	err := this.Conn.WriteJSON(returnMessage{
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
