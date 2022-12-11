package main

import (
	"fmt"
	"log"
	"net/http"
	"server/websocket"
)

func handleWs(pool *websocket.Pool, w http.ResponseWriter, r *http.Request) {
	fmt.Println("main: websocket endpoint hit")
	conn, err := websocket.Upgrade(w, r)
	if err != nil {
		fmt.Fprintf(w, "%+V\n", err)
	}
	client := &websocket.Client{
		Conn:    conn,
		Handler: pool,
	}
	fmt.Println("main: register client")
	pool.Register <- client
	fmt.Println("main: listen on client")
	client.Read() //TODO::::: start as goroutine?????????
}

func main() {
	fmt.Println("main: starting pool")
	pool := websocket.NewPool()
	go pool.Start()
	fmt.Println("main: setup routes")
	//setup routes
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleWs(pool, w, r)
	})
	http.HandleFunc("/admin", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "TODO: Admin GUI here")
	})
	log.Fatalln(
		http.ListenAndServe(":8080", nil),
	)
}
