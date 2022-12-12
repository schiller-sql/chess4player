package websocket

import (
	"fmt"
	"github.com/gorilla/websocket"
	"log"
)

type Client struct {
	Conn    *websocket.Conn // pointer to a websocket.Conn object
	Handler Handler         //pointer to the Pool which this client will be part of
}

type Message struct {
	Type    string                 `json:"type:"`
	SubType string                 `json:"subtype"`
	Content map[string]interface{} `json:"content"`
}

type ClientEvent struct {
	Message Message
	Client  *Client
}

/*
If there are any messages, it will pass these messages to the Pool’s Input channel
which subsequently broadcasts the received message to every client within the pool.
*/
func (this *Client) Read() {
	defer func() {
		this.Disconnect()
	}()

	for {
		var input Message
		err := this.Conn.ReadJSON(&input)
		if err != nil {
			log.Println(err)
			this.Disconnect()
			return
		}
		this.Handler.Input(ClientEvent{input, this})
		fmt.Printf("MessageInput Received: %+v\n", input)
	}
}

func (this *Client) Write(returnType string, returnSubType string, returnContent map[string]interface{}) {
	err := this.Conn.WriteJSON(Message{
		Type:    returnType,
		SubType: returnSubType,
		Content: returnContent,
	})
	if err != nil {
		log.Println(err)
		return
	}
}

func (this *Client) Disconnect() {
	this.Handler.Unregister(this)
	err := this.Conn.Close()
	if err != nil {
		log.Println(err)
		return
	}
}
