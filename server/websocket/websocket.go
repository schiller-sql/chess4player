package websocket

import (
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var Upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func Upgrade(w http.ResponseWriter, r *http.Request) (*websocket.Conn, error) {
	Upgrader.CheckOrigin = func(r *http.Request) bool {
		return true
	}
	ws, err := Upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Println(err)
		return ws, err
	}

	return ws, nil
}
