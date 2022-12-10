package main

import (
	"fmt"
	"log"
	"net/http"
	"server/websocket"
)

/*
create a new Client on every connection and to register that client with a Pool
*/
func handleWs(pool *websocket.Pool, w http.ResponseWriter, r *http.Request) {
	fmt.Println("Websocket endpoint hit")
	conn, err := websocket.Upgrade(w, r)
	if err != nil {
		fmt.Fprintf(w, "%+V\n", err)
	}
	fmt.Println("Remote Address:" + conn.RemoteAddr().String())
	fmt.Println("Local Address:" + conn.LocalAddr().String())
	client := &websocket.Client{
		Conn: conn,
		Pool: pool,
	}

	pool.Register <- client
	client.Read()
}

func main() {
	pool := websocket.NewPool()
	go pool.Start()
	//setup routes
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Simple Server")
	})
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		handleWs(pool, w, r)
	})
	log.Fatalln(http.ListenAndServe(":8080", nil))
}
